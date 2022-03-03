# freja-netrepl
example of using freja to connect to netrepl server

# demo

[REPL another Janet process using Freja (23s)](https://www.youtube.com/watch?v=rl8f16r_8po)

# dependencies

[freja](https://github.com/saikyun/freja)

## if you have [jpm](https://github.com/janet-lang/jpm)

```
jpm install freja
```

# try it

```
git clone https://github.com/saikyun/freja-netrepl/
cd freja-netrepl
freja main.janet
```

1. Hit Ctrl+L (freja-dofile).
2. Ctrl+O (open file), type `test.janet`.
3. Write e.g. `(+ 1 1)`.
4. Hit Alt+B. Check terminal to see results.
