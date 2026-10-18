{ ... }:

{
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  programs.opencode = {
    enable = true;
    settings = {
      provider.homelab = {
        npm = "@ai-sdk/openai-compatible";
        name = "Homelab 3090";
        options = {
          baseURL = "http://192.168.1.220:8080/v1";
          apiKey = "{file:~/.secrets/llama-swap-key}";
        };
        models = {
          gemma-moe = {
            name = "Gemma 4 26B-A4B (3090)";
            reasoning = true;
            interleaved.field = "reasoning_content";
            limit = {
              context = 65536; # allinea al -c di llama-swap
              output = 16384;
            };
          };
          "gemma-moe:nothink" = {
            name = "Gemma 4 26B-A4B no-think (3090)";
            reasoning = false;
            limit = {
              context = 65536;
              output = 16384;
            };
          };
          qwen38 = {
            name = "Qwen3.8-27B (3090)";
            reasoning = true;
            interleaved.field = "reasoning_content";
            limit = {
              context = 49152;
              output = 16384;
            };
          };
        };
      };
      model = "homelab/gemma-moe";
      small_model = "homelab/gemma-moe:nothink";
      share = "disabled";
    };
  };
}
