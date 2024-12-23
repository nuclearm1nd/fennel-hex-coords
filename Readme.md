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

### Updating generic functions

Code in lib/generic folder is added as subtree from abother repo

```bash
git remote add generic http://github.com/nuclearm1nd/fennel-generic-funcs.git
git fetch generic lib
git subtree pull -P lib/generic generic lib
```
