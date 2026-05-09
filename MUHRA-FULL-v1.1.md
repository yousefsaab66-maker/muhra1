# MUHRA — النسخة الكاملة v1.1

وثيقة تسليم وترتيب الموقع (هيكل الصفحات، الـ API، Supabase، النشر).

**اسم الحزمة:** `muhra1` (متطابق مع مشروع Cloudflare_workers عند الحاجة)  
**الدومين الإنتاجي:** `muhrajewelry.com`  
**مستودع GitHub:** `yousefsaab66-maker/muhra1`

---

## 1) التقنية

| الطبقة | التفاصيل |
|--------|-----------|
| إطار | Next.js 16 (App Router)، React 19 |
| أسلوب | `src/app`، Server Actions، Routes API |
| قاعدة البيانات | Supabase (Postgres) |
| الدفع (حالياً) | الدفع عند الاستلام (COD) فقط |
| استضافة | Cloudflare Workers/Pages (OpenNext) — أو أي مزود يدعم Node/Next |

---

## 2) خريطة الموقع (الصفحات العامة)

| المسار | الوظيفة |
|--------|---------|
| `/` | الرئيسية |
| `/products` | كتالوج المنتجات |
| `/products/[slug]` | تفاصيل منتج |
| `/collections`، `/collections/[slug]` | المجموعات |
| `/bag` | السلة |
| `/checkout` | إتمام الطلب (COD) |
| `/checkout/success` | نجاح الطلب |
| `/wishlist` | المفضلة |
| `/account` | الحساب |
| `/story` | القصة |
| `/journal`، `/journal/[slug]` | المجلة |
| `/boutiques` | المتاجر |
| `/bridal`، `/high-jewelry`، `/watches` | أقسام العرض |

---

## 3) لوحة التحكم والأدوار

| المسار | الغرض |
|--------|--------|
| `/staff/login` | تسجيل دخول الموظفين |
| `/staff` | لوحة Staff (منتجات، طلبات، محتوى، أمان) |
| `/admin/login`، `/admin` | مسار أدمن منفصل (إن وُجد في النشر) |

**مهم:** بعد تسجيل الدخول كـ Staff، الطلب يُرسل إلى `/api/staff/session` لتعيين كوكي HTTP-only للعمليات على الخادم (قائمة الطلبات، حفظ المنتجات في Supabase).

---

## 4) واجهات البرمجة (API)

| المسار | الطريقة | الوظيفة |
|--------|---------|---------|
| `/api/catalog/products` | `GET` | جلب المنتجات من Supabase للزوار (بدون تخزين مؤقت عدواني) |
| `/api/staff/session` | `POST` / `DELETE` / `GET` | جلسة الموظف (كوكي موقّع) |

**Server Actions** (ملف `src/app/actions/muhra-backend.ts`): إنشاء الطلب، جلب الطلبات، تحديث الحالة، حذف طلب، إدراج/تحديث/حذف منتج (يحتاج جلسة Staff + `SUPABASE_SERVICE_ROLE_KEY`).

---

## 5) Supabase

### الجداول (بعد تطبيق الـ migration)
- **`products`** — الكتالوج؛ سياسة `products_public_select` للقراءة العامة.
- **`orders`** — الطلبات؛ لا يُتاح للعميل المجهول؛ الكتابة عبر Service Role من الخادم.

### ملف الـ SQL
`supabase/migrations/20250207120000_muhra_products_orders.sql`  
يُنفَّذ مرة واحدة في **Supabase → SQL Editor**.

### متغيرات البيئة (إلزامية للإنتاج)

| المتغير | ملاحظة |
|---------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | رابط المشروع |
| `SUPABASE_SERVICE_ROLE_KEY` | **سري** — للخادم فقط، لا يُعرَّض للمتصفح |
| `STAFF_COOKIE_SECRET` | ≥ 16 حرفًا عشوائيًا |
| `STAFF_USERNAME` | يطابق دخول `/staff/login` ويفضّل أن يطابق إعداد الخادم لـ `/api/staff/session` |
| `STAFF_PASSWORD` | نفس الملاحظة |

مرجع: `.env.example` في جذر المشروع.

---

## 6) سلوك المتجر (ملخص)

- عند فتح الموقع، المتصفح يطلب `/api/catalog/products`: إذا نجح الرد، تُعرض منتجات Supabase لجميع الزوار؛ إذا فشل (مثلاً `backend_not_configured`) يُستخدم الكتالوج التجريبي المحلي.
- **الطلب:** `placeOrder` يستدعي `createOrderRemote` عند توفر الـ backend؛ الدفع مسموح **COD** فقط على الخادم.
- **المنتجات من الـ Staff:** `upsertProductRemote` / `deleteProductRemote` ثم تحديث الكتالوج.

---

## 7) البناء والنشر

```bash
npm install
npm run build
```

- على **Cloudflare:** تأكد أن متغيرات البيئة مُعدّة لمرحلة **Build** و**Runtime** حسب واجهة المشروع.
- الدومين `muhrajewelry.com` يُربط من **Custom domains** في نفس مشروع النشر؛ راقب SSL وعدم خلط DNS مع منصة أخرى (مثل Netlify) لنفس الاسم.

---

## 8) جاهزية التسليم (Checklist)

- [ ] الـ migration منفّذ في Supabase  
- [ ] المتغيرات الخمسة مضبوطة على الاستضافة وتم إعادة النشر بعدها  
- [ ] `/api/catalog/products` يعيد `{"products":[...]}` على الإنتاج  
- [ ] `/staff/login` يعمل + حفظ منتج يظهر لجهاز/متصفح آخر  
- [ ] تجربة طلب COD حتى نجاح الصفحة  
- [ ] الدومين وHTTPS يعملان  

---

## 9) تنبيه عن مجلد «نسخة» قديم على سطح المكتب

أي نسخة لا تحتوي `src/app/api/` و`src/lib/supabase/` **ليست** نسخة الإنتاج v1.1 — لا تُستخدم للنشر. المصدر المعتمد هو هذا المجلد (`MUHRA JEWELRY`) أو فرع `main` على GitHub.

---

*آخر تحديث للوثيقة: v1.1 — تسليم منظّم للموقع والبنية الخلفية.*
