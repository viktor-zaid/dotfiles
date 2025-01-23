{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;

    # Enable viAlias and vimAlias if you want
    viAlias = true;
    vimAlias = true;

    # Install plugins
    plugins = with pkgs.vimPlugins; [
      gruvbox
    ];

    extraLuaConfig = ''
      -- Enable loader and set basic options
      vim.loader.enable()
      vim.opt.termguicolors = true
      vim.g.gruvbox_invert_selection = 0
      vim.cmd.colorscheme("gruvbox")

      -- Window style configuration
      local WINDOW_STYLE = {
        border = 'single',
        style = 'minimal',
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'
      }

      -- Set highlights
      local function set_highlights()
        local highlights = {
          Normal = { bg = '#0f1112' },
          Visual = { bold = false, bg = '#22272b' },
        }

        for group, settings in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, settings)
        end
      end

      set_highlights()

      -- Set various options
      local options = {
        mouse = "",
        number = true,
        guicursor = "n-v-c-i:block",
        relativenumber = true,
        updatetime = 300,
        completeopt = "menu,menuone,noselect",
        autochdir = true
      }

      for k, v in pairs(options) do
        vim.opt[k] = v
      end

      -- Terminal toggle functionality
      local terminal_bufnr = nil
      local last_dir = nil

      local function execute_silent_command(command)
        if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
          local term_chan = vim.b[terminal_bufnr].terminal_job_id
          if term_chan then
            vim.fn.chansend(term_chan, string.format('printf "\\033[A\\033[2K\\033[A\\033[2K" && %s\n', command))
            return true
          end
        end
        return false
      end

      _G.toggle_terminal = function()
        local current_dir = vim.fn.expand('%:p:h')

        if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
          local terminal_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == terminal_bufnr then
              terminal_win = win
              break
            end
          end

          if terminal_win then
            if vim.api.nvim_get_current_win() == terminal_win then
              vim.api.nvim_win_close(terminal_win, true)
            else
              vim.api.nvim_set_current_win(terminal_win)
            end
          else
            vim.cmd('botright split')
            vim.api.nvim_win_set_buf(0, terminal_bufnr)
            if current_dir ~= last_dir then
              execute_silent_command(string.format('cd "%s"', current_dir))
              last_dir = current_dir
            end
          end
        else
          vim.cmd('botright split')
          vim.cmd('lcd ' .. vim.fn.fnameescape(current_dir))
          vim.cmd('term')
          terminal_bufnr = vim.api.nvim_get_current_buf()
          last_dir = current_dir
        end
      end

      -- Smart width resize function
      function _G.smart_width_resize(direction)
        local cur_win = vim.api.nvim_get_current_win()
        local wins = vim.api.nvim_tabpage_list_wins(0)
        local our_pos = vim.api.nvim_win_get_position(cur_win)[2]

        local is_rightmost = true
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_get_position(win)[2] > our_pos then
            is_rightmost = false
            break
          end
        end

        local resize_cmd = string.format('vertical resize %s6',
          (is_rightmost and direction > 0) or (not is_rightmost and direction < 0) and '-' or '+')
        vim.cmd(resize_cmd)
      end

      -- Set all keymaps
      local function set_keymaps()
        -- Terminal related mappings
        vim.api.nvim_set_keymap('n', '<A-CR>', ':lua toggle_terminal()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap('i', '<A-CR>', '<C-o>:lua toggle_terminal()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap('v', '<A-CR>', '<ESC>:lua toggle_terminal()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap('t', '<A-CR>', '<C-\\><C-n>:lua toggle_terminal()<CR>', {noremap = true, silent = true})

        -- Window resize mappings
        vim.keymap.set("n", "<C-w>>", ":lua smart_width_resize(1)<CR>", { noremap = true })
        vim.keymap.set("n", "<C-w><", ":lua smart_width_resize(-1)<CR>", { noremap = true })

        -- Other mappings
        local maps = {
          { mode = 'n', lhs = 'y', rhs = '"+y' },
          { mode = 'v', lhs = 'y', rhs = '"+y' },
          { mode = 'v', lhs = 'x', rhs = '"+x' },
          { mode = 'n', lhs = '<A-l>', rhs = '<Esc>l' },
          { mode = 'n', lhs = 'p', rhs = '"+p' },
          { mode = 'n', lhs = '<Esc>', rhs = ':noh<CR><Esc>' },
          { mode = 'n', lhs = '<C-w>+', rhs = ':resize +5<CR>' },
          { mode = 'n', lhs = '<C-w>-', rhs = ':resize -5<CR>' }
        }

        for _, map in ipairs(maps) do
          vim.keymap.set(map.mode, map.lhs, map.rhs, { noremap = true })
        end

        -- Terminal window navigation
        vim.keymap.set({ 'n', 't' }, '<M-t>', function()
          local terminal_window = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
            if buf_type == 'terminal' then
              terminal_window = win
              break
            end
          end

          if vim.bo.buftype == 'terminal' then
            vim.cmd('wincmd p')
          elseif terminal_window then
            vim.api.nvim_set_current_win(terminal_window)
          end
        end, { noremap = true, silent = true })
      end

      set_keymaps()
    '';
  };
}
