```
 _____   ___  ____   ______  ____   __ __      __    __   ____  ____   ___   
/ ___/  /  _]|    \ |      T|    \ |  T  T    |  T__T  T /    T|    \ |   \  
(   \_ /  [_ |  _  Y|      ||  D  )|  |  |    |  |  |  |Y  o  ||  D  )|    \
\__  TY    _]|  |  |l_j  l_j|    / |  ~  |    |  |  |  ||     ||    / |  D  Y
/  \ ||   [_ |  |  |  |  |  |    \ l___, |    l  `  '  !|  _  ||    \ |     |
\    ||     T|  |  |  |  |  |  .  Y|     !     \      / |  |  ||  .  Y|     |
\___jl_____jl__j__j   l__j  l__j\_jl____/       \_/\_/  l__j__jl__j\_jl_____j
```
# Sentry Ward advanced proxy scanner
![Sentry Ward demo](./images/demo.gif)
***
### Advanced proxy scanner written in pure Dart.
### Supports local proxy lists and remote at the same time.
## Two output formats:
* CSV
* JSON
***
````
 _____   ___  ____   ______  ____   __ __      __    __   ____  ____   ___   
/ ___/  /  _]|    \ |      T|    \ |  T  T    |  T__T  T /    T|    \ |   \  
(   \_ /  [_ |  _  Y|      ||  D  )|  |  |    |  |  |  |Y  o  ||  D  )|    \
\__  TY    _]|  |  |l_j  l_j|    / |  ~  |    |  |  |  ||     ||    / |  D  Y
/  \ ||   [_ |  |  |  |  |  |    \ l___, |    l  `  '  !|  _  ||    \ |     |
\    ||     T|  |  |  |  |  |  .  Y|     !     \      / |  |  ||  .  Y|     |
\___jl_____jl__j__j   l__j  l__j\_jl____/       \_/\_/  l__j__jl__j\_jl_____j


-r, --remote                Urls to remote proxy list [url1,url2,...]

-l, --local                 Paths to proxy list [path1,path2,...]
--socketTimeout             Socket timeout [ms]
                            (defaults to "2000")
                            
--connectTimeout            Connect timeout [ms]
                            (defaults to "5000")
                            
-o, --outputFile            Output file name
                            (defaults to "output.csv")
                            
-f, --outputFormat          Output format: [json, csv]
                            (defaults to "csv")
                            
-h, --help                  Provide usage instruction

-c, --concurrentRequests    Concurrent requests [number]
                            (defaults to "100")
                            
-e, --showErrors            Show errors
````
