#!/usr/bin/env python3
# Talks DLNA (UPnP AV) for main.lua next to it and answers in JSON on stdout;
# errors go to stderr as one line, with exit status 1. Standard library only.
#
#   dlna.py discover [SECONDS]
#       media servers answering on the local network:
#       [{"name", "control", "service"}]
#   dlna.py browse CONTROL SERVICE ID
#       a folder of one of them:
#       [{"dir": true, "id", "title"} | {"title", "url", "sub"}]
#       sub is the URL of a subtitle the server offers with the file, or null

import json
import re
import socket
import sys
import time
import urllib.request
import xml.etree.ElementTree as ET
from urllib.parse import urljoin
from xml.sax.saxutils import escape

SSDP = ("239.255.255.250", 1900)
SERVER = "urn:schemas-upnp-org:device:MediaServer:1"
DIRECTORY = "urn:schemas-upnp-org:service:ContentDirectory:"
PAGE = 500

BROWSE = """<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" \
s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body>\
<u:Browse xmlns:u="{service}"><ObjectID>{id}</ObjectID>\
<BrowseFlag>BrowseDirectChildren</BrowseFlag><Filter>*</Filter>\
<StartingIndex>{start}</StartingIndex><RequestedCount>{count}</RequestedCount>\
<SortCriteria></SortCriteria></u:Browse></s:Body></s:Envelope>"""


def local(tag):
    return tag.rsplit("}", 1)[-1]


def child(el, name):
    return next((c for c in el if local(c.tag) == name), None)


def text(el, name):
    c = child(el, name)
    return (c.text or "").strip() if c is not None else ""


def xml(data):
    # a bad byte in one file name shouldn't hide the whole folder
    s = data.decode("utf-8", "replace") if isinstance(data, bytes) else data
    return ET.fromstring(re.sub(r"^\s*<\?xml[^>]*\?>", "", s))


def fetch(url, body=None, headers=None):
    req = urllib.request.Request(url, body, headers or {})
    with urllib.request.urlopen(req, timeout=15) as r:
        return r.read()


def describe(location):
    root = xml(fetch(location))
    base = text(root, "URLBase") or location
    device = child(root, "device")
    name = text(device, "friendlyName") if device is not None else ""
    for svc in root.iter():
        if local(svc.tag) == "service" and text(svc, "serviceType").startswith(DIRECTORY):
            return {"name": name or location,
                    "control": urljoin(base, text(svc, "controlURL")),
                    "service": text(svc, "serviceType")}
    raise ValueError("no ContentDirectory service")


def discover(wait):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
    search = ("M-SEARCH * HTTP/1.1\r\nHOST: %s:%d\r\nMAN: \"ssdp:discover\"\r\n"
              "MX: 1\r\nST: %s\r\n\r\n" % (SSDP + (SERVER,))).encode()
    # UDP: a lost search would hide a server
    for _ in range(2):
        s.sendto(search, SSDP)
    found = []
    end = time.monotonic() + wait
    while (left := end - time.monotonic()) > 0:
        s.settimeout(left)
        try:
            data = s.recv(65507)
        except socket.timeout:
            break
        for line in data.decode("latin-1").split("\r\n"):
            key, _, value = line.partition(":")
            if key.strip().lower() == "location" and value.strip() not in found:
                found.append(value.strip())
    servers = []
    for location in found:
        try:
            servers.append(describe(location))
        except Exception as e:
            print("%s: %s" % (location, e), file=sys.stderr)
    return sorted(servers, key=lambda s: s["name"].lower())


def entry(el):
    title = text(el, "title")
    if local(el.tag) == "container":
        return {"dir": True, "id": el.get("id"), "title": title}
    kind = re.search(r"(audio|video|image)", text(el, "class"))
    want = kind.group(1) + "/" if kind else ""
    media = fallback = sub = None
    for res in el:
        if local(res.tag) != "res" or not res.text:
            continue
        info = (res.get("protocolInfo") or "").split(":")
        mime = info[2] if len(info) > 2 else ""
        if mime.startswith("text/"):
            sub = sub or res.text.strip()
        elif media is None and want and mime.startswith(want):
            media = res.text.strip()
        elif fallback is None:
            fallback = res.text.strip()
    for c in el:
        if local(c.tag) in ("CaptionInfoEx", "CaptionInfo") and c.text:
            sub = sub or c.text.strip()
    url = media or fallback
    return {"title": title, "url": url, "sub": sub} if url else None


def browse(control, service, oid):
    headers = {"Content-Type": 'text/xml; charset="utf-8"',
               "SOAPAction": '"%s#Browse"' % service}
    out, start = [], 0
    while True:
        body = BROWSE.format(service=escape(service), id=escape(oid),
                             start=start, count=PAGE).encode()
        reply = xml(fetch(control, body, headers))
        fields = {local(e.tag): e.text or "" for e in reply.iter()}
        didl = xml(fields.get("Result") or "<DIDL-Lite/>")
        out += [e for e in map(entry, didl) if e]
        got = int(fields.get("NumberReturned") or 0)
        start += got
        if got == 0 or start >= int(fields.get("TotalMatches") or 0):
            return out


def main(args):
    if args[:1] == ["discover"] and len(args) <= 2:
        result = discover(float(args[1]) if len(args) == 2 else 2)
    elif args[:1] == ["browse"] and len(args) == 4:
        result = browse(*args[1:])
    else:
        sys.exit("usage: dlna.py discover [SECONDS] | browse CONTROL SERVICE ID")
    sys.stdout.buffer.write(json.dumps(result, ensure_ascii=False).encode())


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except Exception as e:
        sys.exit("%s: %s" % (type(e).__name__, e) if str(e) else type(e).__name__)
