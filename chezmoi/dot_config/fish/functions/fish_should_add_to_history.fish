function fish_should_add_to_history
    string match -qr '^\s' -- $argv; and return 1
    string match -qr '[A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD|SESSION)[A-Z0-9_]*=["\']?[^$(\s"\']' -- $argv; and return 1
    string match -qr '^\s*set\s+(-\S+\s+)*[A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD|SESSION)[A-Z0-9_]*\s+["\']?[^$(\s"\']' -- $argv; and return 1
    string match -qr -- '--password[= ]["\']?[^$(\s"\']' $argv; and return 1
    return 0
end
