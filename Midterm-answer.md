NA Midterm Exam
=====
0816146 韋詠祥
2020/04/30

## 1. DHCP
(a) 手動、自動、動態配置
手動配置：由管理員設定各台裝置 MAC address 及 IP address 對照
自動配置：自動發給每台裝置一個永久性的 IP address
動態配置：自動從 pool 中配發，經過特定時間後會失效，可提供其他裝置使用

(b) 應用情境
手動配置：如 NS server 需要維持特定 IP 位址
自動配置：公司內固定使用的電腦，未來需要使用 IP 位址回推使用者時較為方便
動態配置：如公共 Wi-Fi 供不特定人士連線使用

(c) DHCP Ack
當環境中有兩台（或以上）的 DHCP Server 時，可能會收到多個 DHCP Offer，如果直接採用其中一個會導致其他 offer 浪費
而 DHCP Ack 會發送到廣播地址，可以讓其他 server 釋放未被採用的 IP 資源

## 2. Firewall
(a) Stateful / Stateless
Statefull Firewall 會紀錄 ESTABLISHED, RELATED 等 connection 狀態
Stateless Firewall 則是將每個封包視為獨立，不管連線是否存在、是誰發起連線、前面說過什麼

(b) Drop / Reject
若直接將封包 Drop 掉，Client 會以為還在傳輸中/傳輸失敗，將等待或重試
如果 Reject 則會通知無法送達，不必等到 timeout 而是立即知道結果
我是 client 的話會希望看到 Reject 比較乾脆一點，但對方可能會傾向不讀不回，當做沒看到我的封包，讓我不知道是沒這 service 還是被討厭了

(c) TCP half-open
在 Stateful Firewall 會紀錄連線狀態，包含發起連線的 SYN 封包
攻擊者只要大量發送 SYN 封包到被害方，對 firewall 來說是開啟大量連線，將佔用大量資源儲存連線狀態，進而導致正常連線無法被建立
而攻擊者可以射後不理，不管對方傳來的 SYN-ACK 連線以節省資源
搭配上某些網路環境不檢查 Source IP address 的話，用其他人的名義讓被害者握手找不到人，也能隱藏自己身份

## 3. Injection
可以的話使用選項/編號代替文字
如果需要有使用者輸入的文字內容，放進網頁/資料庫語句時該做適當處理
例如儘量正確的使用 library 協助過濾，或正確的逸出相關字串

## 4. DMZ
某些服務需要對外開放，但又需要存取內部網路，若是被壞人取得存取權限，放在 DMZ 並正確設定規則將可控制損害範圍，保護內部網路安全
例如 Mail Server、Web Server、VPN 等服務適合放在 DMZ 中

## 5. VPN
(a) 進入企業內部網路
多數 NAT/Firewall 後面的設備無法透過外網存取，需要 VPN 以內部裝置的角色才能正常使用

(b) 提升網路速度/降低延遲
有時 ISP 提供的路由很差，使用正確的 VPN 將可能可以走更好的路徑
例如租用 Google 彰化機房的 VPS、透過 Google 內網連至外國，可能會比直接以 ISP 提供的路由更好

(c) 補償掉包
在相對惡劣的網路環境下，由於 Packet Loss 過高，會嚴重影響網路使用
曾試過在此條件下連上 VPN，由 VPN 層協助處理掉包問題，當時有改善使用品質

(d) 建立虛擬內網
如 Minecraft 等遊戲若相隔兩地的玩家需要連線，可使用 ZeroTier 等工具建立虛擬網路

## 6. Load Balancer
(a) Scale Up / Scale Out
Scale Up 意指提升伺服器效能，使其能承載更多使用者
Scale Out 則是將工作分給更多伺服器
在規模不大的前提下，前者基本上砸錢就能搞定，但邊際成本較高
後者較有彈性，但更吃技術力，否則可能產生問題

(b) 預防單點失效 / Crossover / 錯誤偵測
預防單點失效：避免因為某核心 server 故障而導致整體服務停擺
Reliable Crossover：當機群產生變化時，架構要能可靠地增加/移除/修改拓樸關係，將流量分配至正確的機器
錯誤偵測：當發生錯誤時，要能正確/快速地因應，避免持續將流量導向失效的機器

(c) Graceful Degradation
當大量使用者湧入伺服器時，如果不做任何預防將導致每個人都不能使用，或是服務品質都很差
可以設定超過某閥值時，將所有/多出的使用者服務降級，或是先讓多出的使用者進入等待頁面
例如地震時氣象局網頁暫時變成純文字以減少資源消耗、線上遊戲於尖峰時段讓使用者進入 queue 等待遊戲開始

## 7. DNS System & Security
(a) Glue Record
在回答 NS record 的同時，也提供對應的 A record
例如查詢 www.nctu.edu.tw 時，如果 edu.tw 的 DNS Server 只告訴我要找 ns.nctu.edu.tw 的話，我可能永遠也不知道是誰
需要同時告訴我 ns.nctu.edu.tw 的 IP 位址才能成功找到最終目標

(b) Backup NS
不一定同個 domain 下所有 service 都放在同個內網裡面，例如 nctu.edu.tw 底下也會有放在 AWS/GCP 的機器，不希望在此網路故障時其他機器也跟著連不上
對於寄信，查不到 MX/A 記錄時會直接退信，但假如查得到記錄，就算當下 Mail Server 無法使用，也還是會放到 queue 等待重試

(c) DNSSEC
支援 DNSSEC 的查詢器該要內建 . (root) 的 Public Key，可以驗證 x.root-servers.net 提供的答案正確性
當向 . (root) 查詢 .tw 的 NS 記錄時，除了有 NS 記錄外，還會用 DS 記錄提供 .tw 的 DNSSEC Public Key Fingerprint，並用 RRSIG 簽署保證其正當性
而 .tw 回應查詢時也會用 RRSIG 簽署 RR，可以拿 DNSKEY 與 DS 記錄上的 key 比對、以 DNSKEY 計算確認 RRSIG 是用該 DNSKEY 簽署

(d) Privacy
兩者均無法用來保護隱私，只能保證回答的正確性
DNSSEC 是保證 Record 正確可信
TSIG 是保證 DNS Server 之間通訊沒被竄改

## 8. DNS & Server Load Balancing
(a) Multiple A Record
優點：簡單暴力
缺點：傳播需要時間、不是每個 client 都一定會隨機挑選 server、同個 client 不能固定連到同一台 server

(b) Multiple CNAME Record
根據 RFC 1912 規範，每個 FQDN 只能設定一個 CNAME 記錄

(c) SRV Record
要看 client 支援度，例如主流瀏覽器不提供此功能

## 9. Change IP Address
可以在更換前幾天將 www 等 record 的 TTL 調低，減少更動到生效所需的傳播時間
事後再調回正常值，避免 DNS 伺服器不穩時影響 web service

## 10. DNS for Private Domain
(a) Reslove from Internet
如果將內網 IP 位址放到公開的 DNS 記錄中，可能會比設定僅限內網存取省事一點，使用者也不用強迫使用內部 DNS Reslover
但如此可能洩漏內部架構資訊，讓攻擊者較好下手，或是進入內網後較容易找到目標

(b) Custom TLD
將自訂 TLD 的 NS 記錄放入內部專用 reslover 即可支援
但所有需存取此 domain 的機器都需要透過指定的 reslover 才可使用，比起使用 internal.example.com 麻煩

## 11. Mail Open Relay
提供不特定人士透過我的 mail server 寄信給他人，像是透過 HiNet 用 NCTU 的名義寄給 Gmail
除了造成其他人困擾，自己的 reputation 也會受到影響

## 12. Mail Receiver Field
在 SMTP 的 RCPT 是給 MTA 看的，決定該信要寄到誰的信箱
而 Mail Header 中的 To 欄位則是給 mail client 看的，不一定與實際收件者相符

## 13. Check Mail Receiver
寄信不限定於一對一，有時會一對多寄信
收件者不一定會出現在 To 欄位，有時會在 Cc 欄位，甚至在 Bcc 欄位或是不顯示
在 Mail Envelope 與 Mail Header 的收件者不相符不代表是惡意信件，如果直接丟棄可能會誤殺正常信件