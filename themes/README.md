# Theme presets

Each `*.yaml` here is a drop-in replacement for the root `config.yaml`.

To switch themes:

```sh
cp themes/dark.yaml config.yaml   # or themes/light.yaml
make build
```

`config.yaml` is always the *active* theme; these files are just saved presets.

| Preset | Look |
|--------|------|
| `light.yaml` | Light background, Georgia serif, blue accent (current default) |
| `dark.yaml`  | Dark terminal background, JetBrains Mono, pink accent |
