-- Capacidades do terminal. É módulo, e não um local no init.lua, porque o
-- plugins/gruvbox.lua precisa do mesmo predicado pra escolher o colorscheme.

local M = {}

local truecolor

-- 24-bit? A fonte é o terminfo, não o COLORTERM: o st não exporta COLORTERM
-- -- nenhum st exporta --, então um gate por env dá falso negativo justamente
-- aqui. O `Tc` do st.info é a mesma capacidade que o nvim consulta pra ligar o
-- termguicolors por conta própria; perguntamos direto porque a detecção dele é
-- assíncrona (ainda não chegou quando o init roda) e, pior, ela só liga a
-- opção, nunca desliga -- no tty ela não desfaria o true que o gruvbox força.
--
-- COLORTERM fica como segunda fonte, pro emulador que anuncia por env (ghostty,
-- kitty) em vez de terminfo.
--
-- Sonda uma vez por sessão: o ColorScheme dispara várias vezes.
function M.truecolor()
    if truecolor ~= nil then
        return truecolor
    end

    local ct = vim.env.COLORTERM
    if ct == "truecolor" or ct == "24bit" then
        truecolor = true
    elseif vim.fn.executable("tput") == 1 then
        -- Tc é a extensão do tmux, que é como o st anuncia; RGB é o nome do
        -- ncurses, usado por entradas direct-color tipo xterm-direct
        truecolor = false
        for _, cap in ipairs({ "Tc", "RGB" }) do
            vim.fn.system({ "tput", cap })
            if vim.v.shell_error == 0 then
                truecolor = true
                break
            end
        end
    else
        truecolor = false
    end

    return truecolor
end

return M
