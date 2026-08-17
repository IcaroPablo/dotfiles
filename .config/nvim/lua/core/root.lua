-- ════════════════════════════════════════════════════════════════════════════
--  root — fonte única de verdade pra "qual é a raiz do projeto"
-- ════════════════════════════════════════════════════════════════════════════
--
-- Atenção à semântica do vim.fs.root, que é contra-intuitiva:
--
--   lista PLANA    { "a", "b" }     → prioridade por MARCADOR: percorre os
--                                     marcadores na ordem e, pra cada um, sobe
--                                     a árvore. O primeiro marcador achado em
--                                     qualquer ancestral ganha, mesmo que esteja
--                                     mais longe que o seguinte.
--   lista AGRUPADA { { "a", "b" } } → prioridade por PROXIMIDADE: os marcadores
--                                     do grupo são equivalentes e o ancestral
--                                     mais próximo ganha.
--
-- Por isso `project` usa lista plana (a ordem é o critério) e `nearest` embrulha
-- num grupo único (a distância é o critério).

local M = {}

-- Ordem = prioridade. Cada entrada existe por um motivo:
--   .git            raiz do repo; vem primeiro pra que um multi-módulo Maven
--                   resolva no repo e não no módulo
--   mvnw/gradlew    raiz do build quando o repo não é git
--   pom.xml         projeto Java solto
--   build.gradle    idem, Gradle
--   lazy-lock.json  a própria config do nvim, que não tem .git (os dotfiles são
--                   um bare repo em ~/.config/dotfiles)
--   .gitignore      último recurso: o $HOME, work-tree dos dotfiles. Só alcança
--                   arquivos que não casaram com nada acima.
M.markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "lazy-lock.json", ".gitignore" }

--- Raiz do projeto do buffer, ou nil se não houver nenhuma.
---@param bufnr integer|nil buffer (default: o atual)
---@return string|nil
function M.project(bufnr)
    return vim.fs.root(bufnr or 0, M.markers)
end

--- Raiz do projeto, caindo no cwd quando não há projeto. Nunca nil.
---@param bufnr integer|nil buffer (default: o atual)
---@return string
function M.dir(bufnr)
    return M.project(bufnr) or assert(vim.uv.cwd())
end

--- Ancestral MAIS PRÓXIMO que contenha um dos marcadores.
--- Para perguntas que não são "qual a raiz do projeto" — por exemplo "onde está
--- o mvnw que eu vou executar" ou "de qual diretório eu rodo o mvn".
---@param markers string[] marcadores equivalentes entre si
---@param bufnr integer|nil buffer (default: o atual)
---@return string|nil
function M.nearest(markers, bufnr)
    return vim.fs.root(bufnr or 0, { markers })
end

return M
