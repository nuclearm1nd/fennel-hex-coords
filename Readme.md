### Testing

Install luaunit package (requires luarocks package manager to be installed)

```bash
make install-deps
```

Run unit tests

```bash
make test
```

Run tests against luajit

```bash
make test LUA_CMD=luajit
```
