return {
    -- Access LLMs with Ollama
    "David-Kunz/gen.nvim",
    opts = {
        show_prompt = true,
        model = "deepseek-coder:7b-instruct",
        display_mode = "split",
        command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
    }
}
