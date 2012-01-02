Metatrader4 Trade Copy tool
===========================

Metatrader4 tool software to copy all trades from one MT4 terminal to one or more terminals - usually connected to other brokers. 

Concept
-----
The tool consists of two main components (MQL4 EA scripts) - TradeCopy Master and TradeCopy Slave. Both terminals need to run on the same computer (or at least need to share one filesystem).

TradeCopy Master - runs on any chart on an MT4 terminal we want to copy trades from.
TradeCopy Slave - runs on any chart of MTterminals we want to copy trades to.

Features
--------

* Copies Market Orders as well as Limit Orders and Stop Orders
* StopLoss and/or TakeProfit are copied properly
* Slaves can adjust Lot sizes - koeficient or fixed lot

Status
------
Currently under development, first working copy released.

TODO
----

* Use kernel32.dll on slaves to read from outside of \experts\files directory
* Handle properly partially closed trades

Other
-----

You might be interested in "auto pilot" trading at http://copytrade.zulutrade.com/ - just copy trades from the best performed traders into your trading platform and earn money


