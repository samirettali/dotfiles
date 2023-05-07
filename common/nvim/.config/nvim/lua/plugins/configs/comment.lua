local present, nvim_comment = pcall(require, "Comment")

if not present then
    return
end

nvim_comment.setup {}
