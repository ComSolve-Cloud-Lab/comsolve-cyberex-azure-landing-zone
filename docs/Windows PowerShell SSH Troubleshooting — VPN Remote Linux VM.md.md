# 🔐 Windows PowerShell SSH Troubleshooting — VPN Remote Linux VM

<p align="center">

![Windows](https://img.shields.io/badge/Windows-10-blue?logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-Troubleshooting-blue?logo=powershell)
![OpenSSH](https://img.shields.io/badge/OpenSSH-9.5p1-green?logo=openssh)
![VPN](https://img.shields.io/badge/VPN-Private%20Network-purple)
![Linux](https://img.shields.io/badge/Linux-Remote%20VM-orange?logo=linux)

</p>

---

## 🎯 Objective

इस troubleshooting scenario का उद्देश्य यह समझना है कि जब:

* VPN connected हो
* Remote Linux VM को `ping` जा रहा हो
* TCP/22 accessible हो
* लेकिन Windows PowerShell से `ssh` command expected तरीके से काम न करे

तो problem को **guess करने के बजाय layer-by-layer कैसे identify और resolve किया जाए।**

इस lab में हमने एक real-world scenario troubleshoot किया जिसमें:

```text
Windows Client
      │
      │ VPN
      ▼
Private Network
      │
      ▼
Remote Linux VM
      │
      │ TCP/22
      ▼
SSH Service
```

---

# 🏗️ Scenario

मान लेते हैं:

```text
Windows Client
VPN IP        : 10.212.134.200

Remote Linux VM
IP            : 192.168.21.207

SSH Username  : <REDACTED>
SSH Password  : <REDACTED>

SSH Port      : 22
```

> ⚠️ वास्तविक username, password और production/private IP addresses इस document में intentionally use नहीं किए गए हैं।

---

# 🚨 Problem Statement

VPN से connect होने के बाद remote Linux VM को ping किया जा रहा था।

लेकिन जब PowerShell से SSH करने की कोशिश की:

```powershell
ssh <USERNAME>@<REMOTE_VM_IP>
```

तो expected SSH login/session नहीं मिला।

पहली नजर में ऐसा लग सकता है कि:

* VPN problem है
* routing problem है
* SSH service down है
* port 22 बंद है
* firewall block कर रहा है

लेकिन troubleshooting में बिना verification के किसी एक कारण को assume नहीं करना चाहिए।

इसलिए हमने problem को layers में divide किया।

---

# 🧠 Troubleshooting Methodology

हमने नीचे के sequence को follow किया:

```text
                SSH Problem
                    │
                    ▼
             Is VPN connected?
                    │
                    ▼
             Can we ping VM?
                    │
                    ▼
             Is TCP/22 open?
                    │
                    ▼
          Is SSH Client available?
                    │
                    ▼
        Which ssh executable runs?
                    │
                    ▼
       Is correct OpenSSH executable
              being executed?
                    │
                    ▼
        SSH Host Key Verification
                    │
                    ▼
          Authentication/Login
```

यह approach important है क्योंकि इससे problem को systematically isolate किया जा सकता है।

---

# 🥇 Step 1 — Verify VPN Connectivity

सबसे पहले verify किया कि Windows machine VPN से connected है।

VPN connected होने के बाद Windows को private network में route मिलना चाहिए।

Architecture:

```text
Windows
10.212.134.200
      │
      │ VPN Tunnel
      ▼
Private Network
      │
      ▼
Remote VM
192.168.21.207
```

VPN disconnect होने पर remote private IP unreachable हो सकता है।

---

# 🥈 Step 2 — Test ICMP Connectivity

Remote VM को ping किया:

```powershell
ping 192.168.21.207
```

Ping successful था।

इससे यह verify हुआ:

```text
Windows
   │
   │ VPN
   ▼
Private Network
   │
   ▼
Remote VM
   │
   └── ICMP ✅
```

### इसका क्या मतलब है?

कम से कम basic IP connectivity available थी।

लेकिन एक important concept:

> **Ping successful होने का मतलब यह नहीं है कि SSH भी necessarily काम करेगा।**

क्योंकि:

```text
ICMP
```

और:

```text
TCP/22
```

अलग protocols हैं।

इसलिए अगला test जरूरी था।

---

# 🥉 Step 3 — Test TCP Port 22

PowerShell में:

```powershell
Test-NetConnection 192.168.21.207 -Port 22
```

Output में मिला:

```text
RemotePort       : 22
TcpTestSucceeded : True
```

इससे verify हुआ कि:

```text
Windows
   │
   │ VPN
   ▼
192.168.21.207
   │
   │ TCP/22
   ▼
   ✅ Reachable
```

### महत्वपूर्ण conclusion

अब हम confidently कह सकते थे कि उस समय:

* VPN path working था
* IP connectivity working थी
* TCP port 22 reachable था

इसलिए immediately firewall या routing को दोष देना सही नहीं होता।

---

# 🔍 Step 4 — Check Windows SSH Command

अब हमने check किया:

```powershell
Get-Command ssh
```

Output:

```text
CommandType     Name
-----------     ----
Application     ssh

Source          C:\Windows\system32\ssh
```

यहाँ एक unusual चीज दिखाई दी।

Expected OpenSSH executable सामान्यतः:

```text
C:\Windows\System32\OpenSSH\ssh.exe
```

होता है।

लेकिन PowerShell किसी दूसरे path को resolve कर रहा था:

```text
C:\Windows\System32\ssh
```

---

# 🔎 Step 5 — Find All SSH Executables

Command:

```powershell
where.exe ssh
```

Output में multiple entries मिलीं:

```text
C:\Users\ADMIN\ssh
C:\Windows\System32\ssh
C:\Windows\System32\OpenSSH\ssh.exe
```

अब problem interesting हो गई।

एक ही `ssh` नाम के multiple candidates मौजूद थे।

---

# 🧠 PowerShell PATH Resolution Concept

जब हम लिखते हैं:

```powershell
ssh
```

तो PowerShell को यह decide करना होता है कि कौन-सा executable/file execute करना है।

Environment `PATH` में कई directories हो सकती हैं।

Conceptually:

```text
ssh
 │
 ├── Candidate 1
 │
 ├── Candidate 2
 │
 └── Candidate 3
```

जिस location को command resolution में पहले match किया जाता है, वह execute हो सकती है।

इसलिए troubleshooting में:

```powershell
Get-Command ssh
```

और:

```powershell
where.exe ssh
```

दोनों useful हैं।

---

# 🚨 Step 6 — Inspect Suspicious `ssh` File

हमने पाया:

```powershell
Get-Item C:\Windows\System32\ssh*
```

Output में:

```text
Name   : ssh
Length : 0
```

यानी:

```text
C:\Windows\System32\ssh
```

एक **0-byte file** थी।

यह actual OpenSSH executable नहीं था।

इसके comparison में actual OpenSSH binary मौजूद थी:

```text
C:\Windows\System32\OpenSSH\ssh.exe
```

---

# 🔐 Step 7 — Verify File Permissions

Suspicious file की permissions check की:

```powershell
Get-Acl C:\Windows\System32\ssh | Format-List
```

इससे पता चला कि file का owner और access permissions Windows system/administrator controlled थे।

इसलिए हमने तुरंत file delete नहीं की।

### Best Practice

Troubleshooting में suspicious file मिलने पर:

```text
❌ तुरंत Delete
```

नहीं करना चाहिए।

पहले:

```text
Identify
   ↓
Inspect
   ↓
Verify
   ↓
Understand impact
   ↓
Then remediate
```

---

# 🧪 Step 8 — Bypass Command Resolution

अब हमने directly actual OpenSSH executable execute किया:

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" <USERNAME>@<REMOTE_VM_IP>
```

यहाँ PowerShell का:

```text
&
```

**Call Operator** है।

इसका मतलब:

> PowerShell को exact executable path देकर उसे execute करना।

इससे PATH resolution bypass हो गया।

---

# 🎯 Unexpected Result — SSH Host Key Warning

इस बार SSH client successfully चला।

लेकिन नया error मिला:

```text
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

और:

```text
Offending ED25519 key in
C:\Users\ADMIN\.ssh\known_hosts
```

यह बहुत important discovery थी।

इसका मतलब:

> अब Windows SSH client काम कर रहा था और remote SSH server तक पहुँच भी रहा था।

Problem अब application/security layer पर shift हो चुकी थी।

---

# 🔐 SSH Host Key क्या होती है?

SSH server की अपनी cryptographic identity होती है।

पहली बार किसी server से connect करते समय उसका host key fingerprint client के:

```text
~/.ssh/known_hosts
```

में save हो सकता है।

Windows पर यह सामान्यतः:

```text
C:\Users\<USER>\.ssh\known_hosts
```

होता है।

Architecture:

```text
First Connection

SSH Client
    │
    ▼
SSH Server
    │
    ▼
Host Key
    │
    ▼
known_hosts
```

अगली बार client उसी IP/hostname से connect करता है तो stored key से comparison होता है।

---

# ⚠️ Why "REMOTE HOST IDENTIFICATION HAS CHANGED"?

पहले client के पास:

```text
192.168.21.207
      ↓
OLD HOST KEY
```

stored थी।

लेकिन server ने अब:

```text
192.168.21.207
      ↓
NEW HOST KEY
```

present की।

इसलिए SSH ने security warning दी।

Possible legitimate reasons:

```text
VM Recreated
      ↓
New SSH Host Key

OR

OS Reinstalled
      ↓
New SSH Host Key

OR

VM Restored / Cloned
      ↓
New SSH Host Key

OR

IP Reassigned
      ↓
Different Server

OR

Potential MITM Attack
      ↓
Security Warning
```

इसलिए इस warning को blindly ignore नहीं करना चाहिए।

---

# 🔎 Step 9 — Identify Offending Known Host Entry

SSH ने exact location बताई:

```text
C:\Users\ADMIN\.ssh\known_hosts:27
```

मतलब line `27` पर पुरानी key मौजूद थी।

---

# 🧹 Step 10 — Remove Old Host Key

यदि server identity independently verified हो चुकी है और यह confirmed legitimate VM है, तो पुराने entry को remove किया जा सकता है:

```powershell
ssh-keygen -R 192.168.21.207
```

Output:

```text
# Host 192.168.21.207 found: line 27
known_hosts updated.
Original contents retained as known_hosts.old
```

### Important

`ssh-keygen -R`:

```text
Old Host Key
     ↓
Remove
     ↓
known_hosts updated
```

और backup के लिए:

```text
known_hosts.old
```

retain कर सकता है।

---

# 🔄 Step 11 — Retry SSH Connection

अब direct OpenSSH executable से फिर connect किया:

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" <USERNAME>@<REMOTE_VM_IP>
```

यहाँ एक महत्वपूर्ण troubleshooting lesson सामने आया।

इस attempt पर:

```text
Connection timed out
```

मिला।

---

# 🤔 क्या Host Key Removal से Problem हुई?

नहीं।

यह दो अलग layers थीं।

पहले:

```text
TCP Connection
     ↓
SSH Server
     ↓
Host Key Check
     ↓
❌ Host Key Mismatch
```

बाद में:

```text
TCP Connection
     ↓
❌ Timeout
```

इसका मतलब network state उस समय बदल चुकी थी।

हमने दोबारा:

```powershell
Test-NetConnection 192.168.21.207 -Port 22
```

और:

```powershell
ping 192.168.21.207
```

से verification करना था।

---

# 💡 Actual Root Cause of the Timeout

दोबारा investigation से पता चला कि:

> **VPN connection temporarily down हो गया था।**

इसलिए:

```text
VPN DOWN
   ↓
Private Route unavailable
   ↓
Remote VM unreachable
   ↓
TCP/22 timeout
```

इसका मतलब timeout का कारण Windows SSH executable नहीं था।

---

# 🧩 Final Root Cause Analysis

इस scenario में एक ही error नहीं था।

हमने अलग-अलग observations identify किए:

### Issue 1 — SSH Command Resolution

Windows में multiple `ssh` candidates मौजूद थे और PowerShell expected OpenSSH executable के बजाय एक problematic 0-byte `ssh` file resolve कर रहा था।

Actual OpenSSH:

```text
C:\Windows\System32\OpenSSH\ssh.exe
```

था।

### Issue 2 — SSH Host Key Mismatch

Actual OpenSSH executable को directly run करने के बाद SSH server की changed host identity detect हुई।

यह `known_hosts` में stored पुराने key से mismatch थी।

### Issue 3 — Temporary VPN Connectivity Loss

Host key issue के बाद subsequent SSH attempt में TCP timeout आया।

Re-verification से पता चला कि VPN connection down हो गया था।

---

# 🏁 Troubleshooting Flow — Final

```text
                    SSH Login Problem
                           │
                           ▼
                    VPN Connected?
                           │
                          YES
                           │
                           ▼
                    Ping Remote VM
                           │
                          YES
                           │
                           ▼
                    Test TCP Port 22
                           │
                          YES
                           │
                           ▼
                   Check SSH Command
                           │
                           ▼
                   Get-Command ssh
                           │
                           ▼
              Unexpected Path Detected
                           │
                           ▼
                    where.exe ssh
                           │
                           ▼
             Multiple SSH Candidates
                           │
                           ▼
              Inspect suspicious file
                           │
                           ▼
                     0-byte file
                           │
                           ▼
           Directly execute OpenSSH binary
                           │
                           ▼
                SSH Client Works
                           │
                           ▼
             Host Key Changed Warning
                           │
                           ▼
             Verify Server Identity
                           │
                           ▼
            Remove stale known_hosts entry
                           │
                           ▼
                   Retry SSH
                           │
                           ▼
                  Connection Timeout
                           │
                           ▼
                Re-check Network
                           │
                           ▼
                    VPN was DOWN
                           │
                           ▼
                    Restore VPN
                           │
                           ▼
                    SSH Connection
                         SUCCESS
```

---

# 🛠️ Commands Used

## 1. Check SSH command

```powershell
Get-Command ssh
```

## 2. Find all SSH locations

```powershell
where.exe ssh
```

## 3. Inspect SSH-related files

```powershell
Get-Item C:\Windows\System32\ssh*
```

## 4. Check file permissions

```powershell
Get-Acl C:\Windows\System32\ssh | Format-List
```

## 5. Check OpenSSH version

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" -V
```

Example:

```text
OpenSSH_for_Windows_9.5p1
```

## 6. Test remote connectivity

```powershell
ping <REMOTE_VM_IP>
```

## 7. Test SSH TCP port

```powershell
Test-NetConnection <REMOTE_VM_IP> -Port 22
```

## 8. Remove stale SSH host key

```powershell
ssh-keygen -R <REMOTE_VM_IP>
```

## 9. Directly execute OpenSSH

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" <USERNAME>@<REMOTE_VM_IP>
```

## 10. Verbose SSH troubleshooting

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" -vvv <USERNAME>@<REMOTE_VM_IP>
```

---

# 📚 Key Concepts Learned

| Concept           | Meaning                                                 |
| ----------------- | ------------------------------------------------------- |
| VPN               | Private network connectivity प्रदान करता है             |
| Ping              | ICMP-level reachability test                            |
| TCP/22            | Standard SSH network port                               |
| OpenSSH Client    | Windows से SSH connection बनाने वाला client             |
| PATH              | Commands के executable locations खोजने का mechanism     |
| `Get-Command`     | PowerShell कौन-सा command resolve कर रहा है यह बताता है |
| `where.exe`       | Available command locations दिखाता है                   |
| Call Operator `&` | Exact executable को execute करता है                     |
| `known_hosts`     | Previously trusted SSH host keys store करता है          |
| Host Key          | SSH server की cryptographic identity                    |
| `ssh-keygen -R`   | Known hosts से पुराने host-key entry को remove करता है  |
| `-vvv`            | Detailed SSH debugging information देता है              |
| TCP Timeout       | TCP connection establish नहीं हो पाया                   |

---

# 🏭 Industrial Troubleshooting Approach

Production environment में इसी तरह troubleshooting करनी चाहिए:

```text
Don't Guess
    ↓
Collect Evidence
    ↓
Check Layer 1
    ↓
Check Layer 2/3
    ↓
Check TCP Port
    ↓
Check Application
    ↓
Check Authentication
    ↓
Identify Root Cause
    ↓
Apply Minimal Fix
    ↓
Verify
    ↓
Document
```

### Example

अगर production Linux server पर SSH नहीं हो रहा:

```text
1. VPN / Network
        ↓
2. Route
        ↓
3. Ping
        ↓
4. TCP/22
        ↓
5. SSH Service
        ↓
6. SSH Client
        ↓
7. Host Key
        ↓
8. Authentication
        ↓
9. User Permissions
```

हर layer को independently verify करना चाहिए।

---

# 🔐 Security Best Practices

### 1. Host Key Warning को blindly bypass न करें

यह command:

```powershell
ssh -o StrictHostKeyChecking=no ...
```

production troubleshooting में बिना समझे use नहीं करनी चाहिए।

क्योंकि इससे host identity verification कमजोर हो सकती है।

---

### 2. Password GitHub पर कभी commit न करें

गलत:

```text
username: root
password: pass@pass
```

सही:

```text
USERNAME=<REDACTED>
PASSWORD=<REDACTED>
```

या environment variables / secret manager का उपयोग करें।

---

### 3. Production में root SSH login avoid करें

जहाँ possible हो:

```text
Normal User
     ↓
sudo
     ↓
Administrative Task
```

का approach prefer किया जाता है।

---

### 4. SSH Keys Prefer करें

Password authentication के बजाय:

```text
SSH Client
    │
    ▼
Private Key
    │
    ▼
SSH Server
    │
    ▼
Public Key Verification
    │
    ▼
Login
```

का उपयोग अधिक secure और automation-friendly होता है।

---

# 🎓 Final Learning

इस पूरे incident से सबसे important lesson:

> **"SSH नहीं चल रहा" एक root cause नहीं है — यह सिर्फ symptom है।**

हमने problem को इस तरह break किया:

```text
VPN
 ↓
IP Connectivity
 ↓
TCP Connectivity
 ↓
SSH Client
 ↓
Executable Resolution
 ↓
Host Identity
 ↓
Authentication
```

और इसी systematic approach की वजह से हम अलग-अलग problems को एक-दूसरे से distinguish कर पाए:

```text
SSH Command Issue
        +
Host Key Mismatch
        +
Temporary VPN Disconnect
```

यही approach real-world **DevOps / Cloud / Infrastructure / Cyber Security troubleshooting** में बहुत useful है।


---