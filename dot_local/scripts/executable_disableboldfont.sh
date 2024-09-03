mkdir "$HOME/.config/fontconfig";
touch "$HOME/.config/fontconfig/fonts.conf";

echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
 <match target="pattern">
   <test qual="any" name="family">
     <string>CozetteVector</string>
   </test>
   <test name="weight" compare="more">
     <const>medium</const>
   </test>
   <edit name="weight" mode="assign" binding="same">
     <const>medium</const>
   </edit>
 </match>
</fontconfig>' > $HOME/.config/fontconfig/fonts.conf;

fc-cache;

