NA Final Exam
=====
0816146 韋詠祥
2020/06/18

## 1. Postfix
(a) Masquerade
如要調整被 masquerade 的欄位，需設定 masquerade_classes 參數
但預設值 envelope_sender, header_sender, header_recipient 已包含 Header From 及 Envelope From，理論上不會有這個狀況

(b) Queues
若是投遞失敗，將移至 deferred queue 等待重試
如果踩到管理員特別設定的規則才會進入 hold queue，等待人工審視後決定下一步如何處理

(c) Checks
在 HELO / EHLO 時 smtpd_helo_restrictions 作用
後續 SMTP 指令分別會進入 smtpd_sender_restrictions、smtpd_recipient_restrictions 等規則
輸入 DATA 指令後，等到 . (end) 時才會輪到 header_checks 及 body_checks 作用

(d) Results
OK 類似 accepted，不會繼續下面的檢查，例如會用在白名單設定
DUNNO 則表示不拒絕，繼續執行下一項檢查
若是途中遇到 OK 則成功，全部 DUNNO 也算成功


## 2. Anti-spam
(a) DNSBL
使用 DNS 查詢某 IP Address 或 Domain Name 是否為 spam addr/DN

例如要對 zen.spamhaus.org 查詢 140.113.99.231 是否為黑單，則會查詢 231.99.113.140.zen.spamhaus.org 的 A 紀錄
回覆 NXDOMAIN 代表此筆記錄不存在於名單中，地址非黑名單，回覆 127.0.0.0/8 則代表此為 spam IP address

(b) Greylist
此機制假設 spammer 為了節省資源，使用非標準 MTA，並將無視伺服器回應、失敗時不會花時間 retry，而正常 MTA 會在收到 Retry later 相關回覆時依照設定過段時間再來
若未設定白名單，即使是已知可信任的來源也要多等很久，較無效率且可能對使用者造成嚴重影響

(c) DKIM
在假設 DNS 可信的前提下，使用 DKIM 簽署信件可保證寄件者為 Domain 擁有者
雖然內文不做驗證，但通常寄件者、收件者、主旨、日期等欄位都會一起簽名，多數狀況下足夠可信

(d) SPF
此紀錄允許列在 cs.nctu.edu.tw MX 紀錄中的 IP 位址、列在 mailer.cs.nctu.edu.tw A 紀錄中的 IP 位址作為合法寄件者
但若是收到不在上述清單的地址也不會立即回絕，而是 softfail 降低可信度、增加進入 spam 收件匣的機會

(e) Mailer SPF
SPF 記錄不會向上層尋找，例如使用 csmx.cs.nctu.edu.tw 寄信就只會檢查 csmx.cs.nctu.edu.tw，就算找不到也不會再往 cs.nctu.edu.tw 檢查

此紀錄只允許 csmx 自己寄出 csmx 的信件，其餘一律強硬拒絕
由於正常來說只有 csmx 自己的系統信件會用 csmx 網域寄發，因此即使這麼設定對正常使用者也不太有潛在影響，我認為是合適的

(f) DMARC
若未通過 SPF / DKIM 則進入隔離區（Spam 收件匣）
並將所有成功、失敗的記錄定期彙整給 postmaster@cs.nctu.edu.tw


## 3. Reduce chcek delay
建置對外的 Mail Gateway 處理 Spam Filtering 及 Virus Scanning 等檢查，通過後轉送給內部 MX Server

內部 MX Server 只接收內部信件、來自 Gateway 的信件、來自信任網路的信件
於此伺服器只做較基本的檢查，節省時間資源


## 4. ICMP
(a) Port Unreachable
在遇到 UDP Port Unreachable 時，目的地電腦會回傳 ICMP 的 Type=3 Destination Unreachable Message 封包，並設定 Code=3 port unreachable

(b) Disable Query
穩定的網路環境平時用不到 ICMP Query，而此功能常被壞人用來探測內部網路環境使用
關閉的害處不多，但可以增加攻擊者測試主機存在與否的難度


## 5. NAT
於 NAT 層會記錄各 Client 的 IP:port 對照到哪個內部伺服器
可以隨機/依負載量選擇新的 client 要給哪台伺服器負責，並維持每個連線只給某伺服器

或是某些情況可以隨機分配，不需顧慮先前分配給哪台伺服器


## 6. LDAP
(a) ACL
例如此規則：
access to attrs=userPassword by * none
access to * by * read

原本任何人都讀不到密碼，若是兩行反過來則變成任何人都讀得到
實務上可能會洩漏敏感資料，或是遭未授權人士竄改重要資料/設定

(b) Overlays
取出資料後、回傳資料前的中介處理層
例如將 userPassword={TOTP1}XXX 轉換為 Code = 123456，並驗證 OTP 是否已被使用過


## 7. SNMP
(a) MIB
這是一種階層式的屬性定義方式，用來作為網路上統一的溝通語言

(b) v2c / v3
SNMP v3 多了身份驗證及傳輸加密的功能，在安全性上較為完善，但實作相對複雜

v2c 會使用 community 區別權限，由於不存在身份驗證，通常各 community 只能以 IP Address 限制允許的來源 IP 位址
v3 的身份驗證允許以帳號密碼驗證登入，管理員在外部網路也能正常執行管理動作

(c) Trap
主動發送告警訊息給管理者
例如於服務下線時通知負責人員，縮短從問題發生到障礙排除所需的時間

(d) Firewall
SNMP 使用 UDP 協議
其中會有向內部 Port 161 連線、Trap 向外部的 Port 162 連線
根據 RFC 6353 還有 Secure SNMP 使用 10161 / 10162，可視需求設定


## 8. Config Management
(a) 必要性
若只有少數幾台機器，未達到此規模，做起來反而比人工各別設定更耗時間

(b) 成本
設定及維護需要諮詢專業人士、商用工具需要授權費用，不一定符合成本效益

(c) 設定複雜度
將單純的設定變得複雜後，可能因此引入安全性漏洞，或導致系統不穩定
於障礙發生時也較難找到錯誤的核心問題

(d) 維護人力
出狀況時需要即時處理，多數工程師不一定有相關經驗及應變能力