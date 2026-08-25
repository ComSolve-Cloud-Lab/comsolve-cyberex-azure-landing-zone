### 📂 Step 1: Google Drive में फोल्डर बनाएं, फोटो अपलोड करें और Public Link निकालें

अगर आपको Google Drive यूज़ करना नहीं आता, तो बस इन आसान स्टेप्स को फॉलो करें:

#### 1️⃣ Google Drive खोलें और नया फोल्डर बनाएं:

* अपने ब्राउज़र (Chrome) में **[drive.google.com](https://drive.google.com)** खोलें।

* स्क्रीन पर ऊपर बाएँ (Left) तरफ **`+ New`** ➕ बटन पर क्लिक करें।

* **`📁 New folder`** विकल्प चुनें।

* फोल्डर का नाम `Signature Images` रखें और **`Create`** पर क्लिक कर दें।

#### 2️⃣ फोल्डर के अंदर फोटो अपलोड करें:

* अभी-अभी बनाए गए `Signature Images` फोल्डर पर डबल-क्लिक करके उसे खोलें।

* फिर से बाएँ तरफ **`+ New`** ➕ बटन पर क्लिक करें।

* इस बार **`📄 File upload`** चुनें।

* अपने कंप्यूटर/मोबाइल से अपनी पासपोर्ट साइज़ फोटो सेलेक्ट करें और **Open / Upload** कर दें।

#### 3️⃣ फोटो को पब्लिक (Shareable) बनाएं:

> ⚠️ **ध्यान दें:** By default Drive की फोटो प्राइवेट होती है। इसे पब्लिक करना ज़रूरी है ताकि ईमेल पाने वाले को फोटो दिखे।

* अपलोड हुई फोटो के ऊपर **Right-Click** 🖱️ करें (मोबाइल में फोटो के पास 3 डॉट्स `⋮` पर टैप करें)।

* **`🔗 Share`** ➔ **`Share`** पर क्लिक करें।

* नीचे **General access** सेक्शन में `Restricted` 🔒 लिखा होगा, उस पर क्लिक करके **`Anyone with the link`** 🌐 सेलेक्ट करें।

* इसके बाद नीचे **`📋 Copy link`** बटन पर क्लिक करें और **`Done`** कर दें।

#### 4️⃣ Direct Image Link (HTML URL) बनाएं:

आपकी कॉपी की गई लिंक ऐसी दिखेगी:

`https://drive.google.com/file/d/1ABC123xyz_EXAMPLE_ID/view?usp=sharing`

* इस लिंक में से **`1ABC123xyz_EXAMPLE_ID`** (जो `/d/` के बाद और `/view` से पहले है) को कॉपी करें।
* इसे नीचे दिए गए फॉर्मेट में `YOUR_FILE_ID` की जगह रख दें:

  `https://lh3.googleusercontent.com/d/YOUR_FILE_ID`

*(यही डायरेक्ट URL आपको अपने HTML कोड के फोटो टैग में यूज़ करना है!)*




### step 2 🛠️ Live Online Editor, Image & Icon Customization & Explanation

Easy and best way to edit file

इस स्टेप में बिना कोई भारी सॉफ्टवेयर (VS Code या Notepad) इंस्टॉल किए—सीधे अपने ब्राउज़र में ऑनलाइन कोड खोलना, अपनी फोटो और आइकन्स के लिंक्स बदलना और कोड का मतलब समझना सीखेंगे।

---

#### 1️⃣ कोड को कहाँ खोलें और लाइव एडिट करें? (बिना किसी इंस्टॉल के)

1. अपने ब्राउज़र (Chrome) में मुफ़्त ऑनलाइन टूल **[htmledit.squarefree.com](https://htmledit.squarefree.com/)** खोलें।

2. इस प्रोजेक्ट का पूरा HTML कोड कॉपी करें और **ऊपर वाले बॉक्स (Top Box)** में पेस्ट कर दें।

3. नीचे वाले बॉक्स (Bottom Box) में आपको तुरंत लाइव डिज़ाइन (Visual Preview) दिखाई देने लगेगा।

4. अब जो भी बदलाव आप ऊपर वाले कोड में करेंगे, उसका लाइव असर तुरंत नीचे दिखेगा!

---

#### 2️⃣ फोटो, नाम और आइकन्स के लिंक्स कैसे बदलें?

##### 🖼️ A. अपनी पासपोर्ट साइज़ फोटो का लिंक बदलें

Step 1 में तैयार की गई अपनी Google Drive की डायरेक्ट लिंक (`https://lh3.googleusercontent.com/d/YOUR_FILE_ID`) निकालें।

* **कोड में लाइन ढूंढें:** `alt="Shrikant P. Nadgaduda"` वाली line.

* **बदलाव करें:** `src="..."` के अंदर अपनी ड्राइव वाली डायरेक्ट लिंक पेस्ट कर दें।

```html

<!-- 🔴 अपनी फोटो की लिंक यहाँ बदलें -->

<img src="[https://lh3.googleusercontent.com/d/YOUR_FILE_ID](https://lh3.googleusercontent.com/d/YOUR_FILE_ID)" alt="Your Name" style="width: 100%; height: 100%; object-fit: cover; object-position: center top; display: block;" />

```
---
### OR
---

### 🛠️ Step 2.1: HTML Code Structure & Complete Explanation

इस स्टेप में हम समझेंगे कि कोड कैसे काम करता है, इसे कहाँ एडिट करना है और अपनी पसंद के आइकन्स (Icons) कैसे लगाने हैं।

---

#### 1️⃣ HTML कोड को कहाँ खोलें और एडिट करें? (How to Edit)

1. अपने सिस्टम में **VS Code** या **Notepad** खोलें।

2. इस प्रोजेक्ट की `index.html` फाइल को उसमें Open करें।

3. एडिट करने के बाद कोड को **Save (`Ctrl + S`)** कर लें।

---
```text

<div style="font-family: 'Segoe UI', Helvetica, Arial, sans-serif; font-size: 14px; color: #111111; line-height: 1.5;">
 
  <!-- Thanks & Regards Section -->
  <div style="font-size: 14px; font-weight: 600; color: #333333; margin-bottom: 10px;"><b>
    Thanks &amp; Regards,</b>
  </div>

  <table style="border-collapse: collapse;">
    <tr>
      <!-- Profile Photo Section -->
      <td style="padding-right: 18px; vertical-align: middle;">
        <div style="width: 90px; height: 90px; border-radius: 50%; overflow: hidden; border: 2.5px solid #0077b5; box-shadow: 0 3px 6px rgba(0,0,0,0.18);">
          <img src="https://lh3.googleusercontent.com/d/1VK8GOlwZ_PjneqZ4VlYGHDFwV2vjkY_2" alt="Shrikant P. Nadgaduda" style="width: 100%; height: 100%; object-fit: cover; object-position: center top; display: block;" />
        </div>
      </td>

      <!-- Vertical Divider -->
      <td style="border-left: 3px solid #0077b5; padding-left: 18px; vertical-align: middle;">
       
        <!-- Name -->
        <div style="font-size: 18px; font-weight: bold; color: #111111; letter-spacing: 0.3px;">Shrikant P. Nadgaduda</div>
       
        <!-- Designation with DevOps Infinity Symbol -->
        <div style="font-size: 13px; font-weight: 700; color: #111111; margin-top: 2px; margin-bottom: 8px;">
          <img src="https://cdn-icons-png.flaticon.com/128/7067/7067847.png" width="20" height="20" alt="DevOps" style="vertical-align: middle; margin-right: 6px;" />
          <span style="vertical-align: middle;">DevOps Engineer &amp; Cloud Specialist</span>
        </div>
       
        <!-- Contact Details -->
        <div style="font-size: 12px; color: #333333; margin-bottom: 10px; line-height: 1.6;">
          📧 <a href="mailto:shri.gaudaa@gmail.com" style="color: #0066cc; text-decoration: underline; font-weight: 500;">shri.gaudaa@gmail.com</a><br />
          📧 <a href="mailto:vyankatesh151@gmail.com" style="color: #0066cc; text-decoration: underline; font-weight: 500;">vyankatesh151@gmail.com</a><br />
          📱 <a href="tel:+919172199631" style="color: #111111; text-decoration: none; font-weight: bold;">+91 9172199631</a>
        </div>

        <!-- Social Profiles & Tech Stack Icons -->
        <div style="line-height: 1;">
          <!-- LinkedIn (Clickable) -->
          <a href="https://www.linkedin.com/in/shrikant-nadgauda" target="_blank" title="LinkedIn Profile" style="text-decoration: none; margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/256/174/174857.png" width="20" height="20" alt="LinkedIn" style="vertical-align: middle;" />
          </a>
         
          <!-- GitHub (Clickable) -->
          <a href="https://github.com/Shrikant-Nadgaudaa/" target="_blank" title="GitHub Profile" style="text-decoration: none; margin-right: 12px;">
            <img src="https://cdn-icons-png.flaticon.com/256/25/25231.png" width="20" height="20" alt="GitHub" style="vertical-align: middle;" />
          </a>

          <!-- Divider -->
          <span style="color: #ccc; margin-right: 10px; font-size: 12px;">|</span>

          <!-- Docker -->
          <span title="Docker" style="margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/512/919/919853.png" width="20" height="20" alt="Docker" style="vertical-align: middle;" />
          </span>

          <!-- Kubernetes -->
          <span title="Kubernetes" style="margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/512/1126/1126012.png" width="20" height="20" alt="Kubernetes" style="vertical-align: middle;" />
          </span>

          <!-- CI/CD -->
          <span title="CI/CD" style="margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/512/1006/1006771.png" width="20" height="20" alt="CI/CD" style="vertical-align: middle;" />
          </span>

          <!-- Git -->
          <span title="Git" style="margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/128/2111/2111288.png" width="20" height="20" alt="Git" style="vertical-align: middle;" />
          </span>

          <!-- Firewall -->
          <span title="Firewall Security" style="margin-right: 8px;">
            <img src="https://cdn-icons-png.flaticon.com/128/6071/6071236.png" width="20" height="20" alt="Firewall" style="vertical-align: middle;" />
          </span>

          <!-- AI -->
          <span title="AI Integration">
            <img src="https://cdn-icons-png.flaticon.com/128/18111/18111997.png" width="20" height="20" alt="AI" style="vertical-align: middle;" />
          </span>

        </div>

      </td>
    </tr>
  </table>
</div>

```
---

#### 2️⃣ Code Explanation (शब्द-दर-शब्द आसान भाषा में)

यहाँ कोड के हर टैग और CSS प्रॉपर्टी का गहराई से मतलब समझाया गया है:

##### **A. Main Container (`<div>` & Text Styling)**
`<div style="font-family: 'Segoe UI', Helvetica, Arial, sans-serif; font-size: 14px; color: #111111; line-height: 1.5;">`

* **`<div>`**: यह एक ब्लॉक (कंटेनर) बनाता है जो पूरे सिग्नेचर को अपने अंदर रखता है।

* **`font-family`**: टेक्स्ट का फॉन्ट सेट करता है। अगर सिस्टम में `'Segoe UI'` नहीं है, तो वह अपने आप `Helvetica` या `Arial` का उपयोग करेगा।

* **`font-size: 14px`**: डिफ़ॉल्ट अक्षर का आकार 14 पिक्सल तय करता है।

* **`color: #111111`**: टेक्स्ट का रंग गहरा काला (Dark Black) रखता है।

* **`line-height: 1.5`**: दो लाइनों के बीच 1.5 गुना जगह (gap) देता है ताकि पढ़ने में आसानी हो।

---

##### **B. Layout Table Structure (`<table>`, `<tr>`, `<td>`)**
`<table style="border-collapse: collapse;">`

* **`<table>`**: ईमेल क्लाइंट्स (Gmail, Outlook) में लेआउट को हिलने से बचाने के लिए टेबल का उपयोग सबसे सुरक्षित होता है।

* **`border-collapse: collapse`**: टेबल की अंदरूनी सीमाओं (borders) के बीच का गैप खत्म कर देता है।

* **`<tr>` (Table Row)**: यह एक सीधी पंक्ति (Row) बनाता है।

* **`<td>` (Table Data / Column)**: यह कॉलम बनाता है। यहाँ 2 कॉलम हैं:

  1. **पहला Column (`<td>`)**: इसमें आपकी प्रोफाइल फोटो है (`padding-right: 18px` से दाईं तरफ गैप दिया गया है)।

  2. **दूसरा Column (`<td>`)**: इसमें नीली वर्टिकल लाइन (`border-left: 3px solid #0077b5`) के साथ आपकी सारी डिटेल्स हैं।

* **`vertical-align: middle`**: फोटो और कंटेंट को ऊपर-नीचे से एकदम बीच (Center) में अलाइन रखता है।

---

##### **C. Profile Photo Box Styling (`<div>` & `<img>`)**

`<div style="width: 90px; height: 90px; border-radius: 50%; overflow: hidden; border: 2.5px solid #0077b5; box-shadow: 0 3px 6px rgba(0,0,0,0.18);">`
`<img src="..." style="width: 100%; height: 100%; object-fit: cover; object-position: center top; display: block;" />`

* **`width & height: 90px`**: फोटो के फ्रेम का साइज़ 90x90 पिक्सल फिक्स करता है।

* **`border-radius: 50%`**: चोकोर फोटो को एकदम गोल (Circle) बना देता है।

* **`overflow: hidden`**: गोल फ्रेम से बाहर जाने वाले फोटो के हिस्सों को काट देता है।

* **`border: 2.5px solid #0077b5`**: गोल फोटो के चारों ओर नीली बाउंड्री बनाता है।

* **`box-shadow`**: फोटो के पीछे हल्की परछाईं (Shadow) देता है।

* **`object-fit: cover`**: फोटो खिंचने या चपटी होने के बजाय सही रेश्यो में एडजस्ट होती है।

* **`object-position: center top`**: चेहरे को फोटो के केंद्र/ऊपर फोकस में रखता है।

---

##### **D. Name, Title & DevOps Symbol**
`<div style="font-size: 18px; font-weight: bold; color: #111111; letter-spacing: 0.3px;">`

* **`font-weight: bold / 700`**: टेक्स्ट को मोटा (Bold) बनाता है।

* **`letter-spacing: 0.3px`**: अक्षरों के बीच हल्का गैप देता है।

* **`margin-top` / `margin-bottom`**: ऊपर और नीचे से दूरी (Spacing) सेट करता है।

* **`<span>`**: बिना नई लाइन बनाए केवल टेक्स्ट के किसी हिस्से को अलग स्टाइल करने के लिए यूज़ होता है।

---

##### **E. Links & Interactive Buttons (`<a>` Tag)**

`<a href="mailto:shri.gaudaa@gmail.com" style="color: #0066cc; text-decoration: underline;">`
`<a href="https://..." target="_blank" title="LinkedIn Profile">`

* **`<a>` (Anchor Tag)**: क्लिक करने योग्य लिंक बनाता है।

* **`href="mailto:..."`**: क्लिक करने पर डायरेक्ट ईमेल भेजने का विंडो खोलता है।

* **`href="tel:..."`**: मोबाइल में क्लिक करने पर डायरेक्ट कॉल डायलर खोलता है।

* **`target="_blank"`**: लिंक पर क्लिक करने पर उसे ब्राउज़र के नए टैब (New Tab) में खोलता है।

* **`text-decoration: underline / none`**: टेक्स्ट के नीचे की लाइन दिखाता या हटाता है।

* **`title="..."`**: माउस का कर्सर ऊपर ले जाने पर नाम का छोटा टूलटिप दिखाता है।


---

#### 3️⃣ नए Icons कहाँ से लाएं और Link कैसे बदलें?

##### 🔹 Step A: Icon डाउनलोड / लिंक कॉपी कहाँ से करें?

1. अपने ब्राउज़र में **[Flaticon.com](https://www.flaticon.com/)** वेबसाइट खोलें।

2. सर्च बार में अपनी पसंद का टूल टाइप करें (उदा: `docker`, `kubernetes`, `aws`, `python`).

3. जो आइकॉन पसंद आए, उस पर **Right-Click** 🖱️ करें और **`Copy Image Address`** (या *Copy Image Link*) सेलेक्ट करें।

##### 🔹 Step B: Code में Icon Link कैसे बदलें?


कोड में जिस आइकॉन को बदलना है, उसके `<img src="..." />` वाले हिस्से को ढूंढें और `src` के अंदर का URL रिप्लेस कर दें।

**उदाहरण (Docker Icon बदलना):**

```html
<!-- बदलने से पहले -->
<span title="Docker" style="margin-right: 8px;">
  <img src="[https://cdn-icons-png.flaticon.com/512/919/919853.png](https://cdn-icons-png.flaticon.com/512/919/919853.png)" width="20" height="20" alt="Docker" style="vertical-align: middle;" />
</span>

<!-- बदलने के बाद (अपना नया URL डालें) -->
<span title="Docker" style="margin-right: 8px;">
  <img src="YOUR_NEW_FLATICON_URL_HERE" width="20" height="20" alt="Docker" style="vertical-align: middle;" />
</span>
```

---


### 📩 Step 3: Gmail में नया Signature कैसे बनाएं या पुराना कैसे बदलें?

इस स्टेप में हम ऑनलाइन एडिटर से अपना तैयार डिज़ाइन कॉपी करके Gmail में नया सिग्नेचर लगाना या पुराने सिग्नेचर को बदलना सीखेंगे। 

---

#### 1️⃣ ऑनलाइन एडिटर से डिज़ाइन Copy करें
1. सबसे पहले अपने ब्राउज़र में खोला हुआ ऑनलाइन एडिटर **[htmledit.squarefree.com](https://htmledit.squarefree.com/)** देखें।
2. **नीचे वाले बॉक्स (Bottom Box)** में आपको आपकी फोटो, नाम और आइकन्स वाला सुंदर डिज़ाइन दिख रहा होगा।
3. अपने माउस के कर्सर से उस पूरे डिज़ाइन को **सेलेक्ट / हाईलाइट (Highlight)** करें (फोटो से लेकर नीचे के आइकन्स तक)।
4. अपने कीबोर्ड से **`Ctrl + C`** दबाकर उस visual design को कॉपी कर लें।

---

#### 2️⃣ Gmail Settings में जाएं
1. अपने कंप्यूटर पर **[Gmail](https://mail.google.com)** खोलें।
2. स्क्रीन पर ऊपर दाईं तरफ दिए गए **Settings ⚙️ (गियर)** आइकॉन पर क्लिक करें।
3. इसके बाद **`See all settings`** (सभी सेटिंग देखें) बटन पर क्लिक करें।
4. **General (सामान्य)** टैब में ही रहें और नीचे की तरफ स्क्रॉल (Scroll) करें, जब तक आपको **Signature** वाला सेक्शन न मिल जाए।

---

#### 3️⃣ नया Signature बनाएं (New Signature)
अगर आप पहली बार सिग्नेचर बना रहे हैं:
1. **`+ Create new`** (नया बनाएं) बटन पर क्लिक करें।
2. अपने सिग्नेचर का कोई भी नाम रखें (जैसे: `DevOps Official`) और **Create** पर क्लिक करें।
3. दाहिने तरफ एक खाली सफेद बॉक्स (Text Box) दिखाई देगा।
4. उस खाली बॉक्स के अंदर क्लिक करें और कीबोर्ड से **`Ctrl + V`** दबाकर अपना कॉपी किया हुआ डिज़ाइन पेस्ट कर दें।

---

#### 4️⃣ पुराना Signature कैसे बदलें / अपडेट करें? (Edit Existing Signature)
अगर आपका Gmail में पहले से कोई पुराना सिग्नेचर बना हुआ है:
1. Signature सेक्शन में अपने पुराने सिग्नेचर के नाम पर क्लिक करें।
2. दाहिने तरफ वाले बॉक्स में जो पुराना कंटेंट है, उसे माउस से सेलेक्ट करके **Delete** कर दें।
3. अब उसी खाली बॉक्स में क्लिक करें और **`Ctrl + V`** दबाकर अपना नया डिज़ाइन पेस्ट कर दें।

---

#### 5️⃣ Signature Defaults सेट करें (अति महत्वपूर्ण ⚠️)
पेस्ट करने के बाद सिग्नेचर बॉक्स के ठीक नीचे **Signature defaults** का ऑप्शन दिखेगा:

* **For new emails use**: इसमें ड्रॉपडाउन पर क्लिक करके अपने बनाए गए सिग्नेचर का नाम (`DevOps Official`) सेलेक्ट करें।
* **On reply/forward use**: इसमें भी अपने सिग्नेचर का नाम सेलेक्ट करें, ताकि किसी को रिप्लाई करते वक्त भी आपका सिग्नेचर अपने आप आ जाए।

---

#### 6️⃣ Save Changes (बदलाव सुरक्षित करें)
1. पेज के सबसे नीचे तक स्क्रॉल (Scroll) करें।
2. **`Save Changes`** (बदलाव सहेजें) बटन पर क्लिक करें।

🎉 **बधाई हो!** अब जब भी आप Gmail में **Compose** (नया ईमेल लिखने) पर क्लिक करेंगे, आपका यह एकदम प्रोफेशनल DevOps सिग्नेचर अपने आप तैयार मिलेगा!

---