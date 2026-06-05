if status is-interactive

    fish_add_path ~/.bin
    fish_add_path ~/.cargo/bin
    fish_add_path ~/.local/share/nvim/mason/bin
    fish_add_path ~/go/bin
    fish_add_path ~~/.npm-global

    set -g fish_history_size 10000
    set -gx EDITOR nvim
    set -g async_prompt_functions _pure_prompt_git

    fish_config theme choose catppuccin-mocha --color-theme dark

    alias eza='eza --icons=always --color=always -h'
    alias l='eza -l --sort=type'
    alias la='eza -al --sort=type'
    alias ld='eza -lD'
    alias lS='eza -al --sort=size'
    alias lm='eza -al --sort=modified'
    alias lt='eza -l --tree'
    alias vim='nvim'
    alias lg='lazygit'
    alias rm='rm -r -i'
    alias on='z ~/vault/iz/ && nvim start_page.md'

    function v
        if test (count $argv) -gt 0
            nvim $argv
        else
            set file (fd -t f -t l --color=always --strip-cwd-prefix=always | \
				fzf --height 30% --ansi --preview 'bat --style=numbers --color=always --line-range :200 {}')
            if test -n "$file"
                nvim "$file"
            end
        end
    end

    function vh
        if test (count $argv) -gt 0
            nvim $argv
        else
            set file (fd -H -t f -t l --color=always --strip-cwd-prefix=always | \
				fzf --height 30% --ansi --preview 'bat --style=numbers --color=always --line-range :200 {}')
            if test -n "$file"
                nvim "$file"
            end
        end
    end

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function fzf
        functions -e fzf
        fzf --fish | source
        fzf $argv
    end

    function z
        functions -e z
        zoxide init fish | source
        z $argv
    end

    function zi
        functions -e zi
        zoxide init fish | source
        zi $argv
    end

    set -g async_prompt_functions _pure_prompt_git
    source ~/.config/fish/keybinds.fish

end
