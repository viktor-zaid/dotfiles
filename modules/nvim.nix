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
      end

      set_keymaps()
    '';
  };
}

