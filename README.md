Free MT4 Trade Copier
=====================

Metatrader4 tool software to copy all trades from one MT4 terminal to one or more terminals - usually connected to other brokers. It uses pure MQL4 language for all the logic. The Windows core kernel32.dll library is used for reading from outside of `experts\files` directory on Windows. On Linux (running under Wine) it is not necessary, one could make a symbolic (or hard-) link to share one file under different directories.

Concept
-----
The tool consists of two main components (MQL4 EA scripts) - _TradeCopy Master_ and _TradeCopy Slave_.

* **TradeCopy Master** - runs on any chart on an MT4 terminal we want to copy trades from. It writes all necessar info into a file as soon as any change happens (new trade, SL or TP change, close trade, etc.)
* **TradeCopy Slave** - runs on any chart of MT4 terminals we want to copy trades to. It reads the status file regurarly and react accordingly as soon as any change occurs.

MT4 terminal with the _TradeCopty Master_ as well as all terminals with _TradeCopy Slave_ need to run on the same computer (or at least need to share one filesystem). The original idea came from user Николай published in [Automated Trading and Strategy Testing](http://www.mql5.com/en/articles/189) article on mql5.com.


Features
--------

* Copies Market Orders as well as Limit Orders and Stop Orders
* StopLoss and/or TakeProfit are copied properly
* Slaves can adjust Lot sizes - koeficient or fixed lot

Status
------
Currently under development, first working copy tested. The sharing/accessing the same file (TradeCopy.csv) from master and all slaves must be provided on a system level (via link under Linux). Windows users need to wait until a new feature is implemented - read a file outside own subdirectory via kernel32.dll.

TODO
----

* Use kernel32.dll on slaves to read from outside of own `\experts\files` directory
* Handle properly partially closed trades
* Maybe in the future: Copy trades over the network via 0MQ library (http://www.zeromq.org) - see the idea: http://codebase.mql4.com/7147

Other
-----

You might be interested in "auto pilot" trading at http://copytrade.zulutrade.com/ - just copy trades from the best performed traders into your trading platform and earn money

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=vobornik&url=https://github.com/vobornik/mt4-trade-copy&title=Free MT4 Trade Copier&language=&tags=github&category=software) 
