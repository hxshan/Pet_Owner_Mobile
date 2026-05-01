# 📋 Full UAT Test Cases — Pet Owner Mobile App

---

## 🔐 Module 0 — Authentication & Onboarding

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| AUTH-01 | Splash screen loads | Launch the app | Splash screen shown, then navigates to Welcome/Get Started page | |
| AUTH-02 | Welcome / Get Started page | Tap Get Started | Navigates to Sign Up flow | |
| AUTH-03 | Sign up — Step 1: Account info (valid) | Enter NIC, email, password → Next | Proceeds to next step | |
| AUTH-04 | Sign up — missing NIC | Leave NIC blank → Next | Validation error shown | |
| AUTH-05 | Sign up — invalid email format | Enter `notanemail` → Next | Email validation error shown | |
| AUTH-06 | Sign up — Step 2: Personal info (valid) | Enter first name, last name, phone, address → Next | Proceeds to next step | |
| AUTH-07 | Sign up — Step 3: Animal/pet info | Complete pet info step → Submit | Account created; user redirected to login or dashboard | |
| AUTH-08 | Login — valid NIC and password | Enter correct NIC + password → Login | User authenticated and navigated to Dashboard | |
| AUTH-09 | Login — empty NIC | Leave NIC blank → Login | "NIC is required" error shown | |
| AUTH-10 | Login — empty password | Leave password blank → Login | "Password is required" error shown | |
| AUTH-11 | Login — wrong credentials | Enter wrong NIC/password → Login | Error message shown; login blocked | |
| AUTH-12 | Password visibility toggle | Tap eye icon on password field | Password toggles between hidden and visible | |
| AUTH-13 | Navigate from login to sign up | Tap sign up link on Login page | Navigates to Sign Up flow | |
| AUTH-14 | Session persistence | Login, close and reopen app | User remains logged in; redirected to Dashboard | |
| AUTH-15 | Logout | Logout from Profile page | Session cleared; user redirected to Login page | |

---

## 🧑 Module 1A — User Profile

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| UP-01 | View profile page | Navigate to Profile tab | First name, last name, email, phone, address, profile image, NIC, active pets count, and appointments count are displayed | |
| UP-02 | Edit profile — valid data | Tap Edit Profile → update name/phone/address → Save | Changes saved and reflected on Profile page | |
| UP-03 | Edit profile — empty required fields | Clear first name or last name → Save | Validation error shown; save blocked | |
| UP-04 | Upload/change profile photo | Tap profile image → select from gallery | New image displayed on Profile page | |
| UP-05 | NIC verification badge visible | Open Profile page | NIC number shown with verified/unverified status badge | |
| UP-06 | Active pet count correct | Register pets and view Profile | Active pets count matches registered pets | |
| UP-07 | Change password — valid | Enter correct current password + matching new passwords → Submit | Password changed; success shown | |
| UP-08 | Change password — wrong current password | Enter incorrect current password → Submit | Error message displayed | |
| UP-09 | Change password — mismatch confirm | New password ≠ confirm password → Submit | "Passwords do not match" error shown | |
| UP-10 | View Help & Support | Tap Help & Support | Screen loads with support content | |
| UP-11 | View Privacy Policy | Tap Privacy Policy | Privacy Policy text displayed | |
| UP-12 | View Terms & Conditions | Tap Terms & Conditions | Terms & Conditions text displayed | |

---

## 🐾 Module 1B — Pet Profile Management

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| PP-01 | View all pets | Navigate to My Pets | All pets listed with name, species, and breed | |
| PP-02 | View all pets — empty state | No pets registered | Empty state message displayed | |
| PP-03 | Add pet — all valid fields | Fill name, breed, species, DOB, weight, color, health status, life status → Submit | Pet created and appears in My Pets list | |
| PP-04 | Add pet — missing name | Leave name blank → Submit | Validation error shown | |
| PP-05 | Add pet — species dropdown | Tap species dropdown | Dog, Cat, Bird, Rabbit, Hamster, Other available | |
| PP-06 | Add pet — health status options | Tap health dropdown | Good, Fair, Poor, Critical available | |
| PP-07 | Add pet — life status options | Tap life status dropdown | Alive, Deceased available | |
| PP-08 | View individual pet profile | Tap a pet | Profile shows name, species, breed, gender, DOB, health, life status, profile image | |
| PP-09 | Upload pet profile photo | Tap pet image on profile → pick from gallery | New photo displayed | |
| PP-10 | Edit pet — update valid field | Navigate to Edit Pet → change field → Save | Change saved and reflected | |
| PP-11 | Delete / manage pet | Navigate to pet management | Options to edit or remove the pet are accessible | |
| PP-12 | QR code visible on pet profile | Open pet profile | QR code generated and displayed | |
| PP-13 | Share pet profile via QR | Tap share icon | Share sheet opens with QR code | |
| PP-14 | Upcoming appointments on profile | Pet has booked appointments | Appointment cards listed under pet profile | |
| PP-15 | No appointments state | Pet has no appointments | Empty state or "No upcoming appointments" shown | |
| PP-16 | Vaccinations on pet profile | Pet has vaccination records | Vaccination cards shown | |
| PP-17 | View all pets list (alternate page) | Navigate to View All Pets | Full paginated/scrollable list of pets | |

---

## 💉 Module 1C — Vaccinations

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| VC-01 | View vaccination list | Navigate to Vaccinations | All vaccination records listed | |
| VC-02 | Vaccination card details | View any vaccination card | Shows vaccine name, dose, route, manufacturer, batch number, administered date, next due date, status | |
| VC-03 | Overdue status badge | Record with past next-due date | "Overdue" badge shown | |
| VC-04 | Upcoming status badge | Record with future next-due date | "Upcoming" badge shown | |
| VC-05 | Completed status badge | Record marked completed | "Completed" badge shown | |
| VC-06 | Empty vaccination state | No records exist | Empty state message displayed | |
| VC-07 | Pull to refresh | Pull down on Vaccinations page | List reloads from server | |

---

## 📋 Module 1D — Medical Reports & Appointments

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| MR-01 | View medical history | Navigate to Medical History | Report cards listed (type, date, doctor) | |
| MR-02 | Medical report card info | View a card | Shows report type (e.g. X-Ray), date, doctor name, and icon | |
| MR-03 | View upcoming appointments | Navigate to Upcoming Appointments | All upcoming appointments listed | |
| MR-04 | Appointment detail view | Tap appointment card | Full appointment details page opens with vet, clinic, pet info | |
| MR-05 | Chat with vet | Navigate to Chat screen from pet management | Chat screen opens for vet communication | |

---

## 🔍 Module 1E — AI Symptom Checker & Diagnosis

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| SC-01 | Open with linked pet | Launch from pet profile | Pet name, breed, species, age, weight pre-filled | |
| SC-02 | Open without linked pet | Launch without pet ID | Fields blank; user can fill manually | |
| SC-03 | Landing step navigation | View landing step | Options to use Symptom-based or Photo-based diagnosis | |
| SC-04 | Select single symptom | Choose one symptom | Symptom highlighted; selected count = 1 | |
| SC-05 | Select multiple symptoms across categories | Select symptoms from multiple categories | All retained; count updates correctly | |
| SC-06 | Submit symptoms — valid | At least one symptom selected → Submit | AI result: condition, confidence %, severity, description, recommended action | |
| SC-07 | Submit symptoms — none selected | Tap Submit with zero symptoms | Prompt/error to select at least one symptom | |
| SC-08 | OTC medication in result | AI returns OTC medication | OTC medication field visible in result card | |
| SC-09 | Photo upload — gallery | Switch to Photo Upload → pick from gallery → Submit | Photo uploaded; AI returns condition, confidence, severity, common causes, action | |
| SC-10 | Photo upload — camera | Use camera to capture → Submit | Captured image analyzed; results returned | |
| SC-11 | Photo analysis loading state | Submit a photo | Loading indicator with phased status text shown during analysis | |
| SC-12 | Multiple CNN predictions | API returns multiple predictions | All listed with confidence % and severity | |
| SC-13 | Photo analysis failure | Submit unrecognizable image | Error message shown; user can retry | |
| SC-14 | Species-specific symptoms | Change species between Dog/Cat | Symptom categories and options update for species | |
| SC-15 | Pet detail fields — species | Select Dog vs Cat manually | Relevant pet profile fields activate | |
| SC-16 | Navigate back mid-flow | Tap back from symptoms step | Returns to previous step without losing entered data | |
| SC-17 | Navigate back from results | Tap back on results screen | Returns cleanly to previous step | |

---

## 🛒 Module 2 — E-Commerce

### 2A — Product Discovery

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-01 | View ecommerce dashboard | Navigate to Shop | Promo banner, category filters, and featured products grid displayed | |
| EC-02 | Category filter — All | Select "All" category | All products shown | |
| EC-03 | Category filter — specific | Select Food, Toys, Accessories, Health, etc. | Filtered products shown for that category | |
| EC-04 | Search products — valid keyword | Type a product name in search | Matching products listed | |
| EC-05 | Search products — no results | Search for non-existent product | Empty state or "No products found" shown | |
| EC-06 | Advanced search screen | Navigate to search view screen | Search filters or results page loads | |
| EC-07 | View product detail | Tap a product card | Detail page loads: images, name, price, category, description, store name, location, rating, reviews | |
| EC-08 | Product image gallery | Swipe product images on detail page | Additional images visible | |
| EC-09 | Product rating and review count | Open product detail | Rating stars and review count displayed | |
| EC-10 | Store name and location visible | Open product detail | Store name and location shown | |

### 2B — Cart

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-11 | Add to cart from product detail | Tap "Add to Cart" | Success toast; cart item count updates | |
| EC-12 | Adjust quantity before adding | Change quantity to 3 → Add to Cart | 3 units added to cart | |
| EC-13 | View cart | Navigate to Cart | All cart items listed with product image, name, price, qty | |
| EC-14 | Cart total calculation | View cart with multiple items | Subtotal = sum of (price × qty) for all items | |
| EC-15 | Update item quantity in cart | Increase/decrease qty in cart | Cart total updates accordingly | |
| EC-16 | Remove item from cart | Remove an item | Item removed; total recalculated | |
| EC-17 | Empty cart state | Cart has no items | Empty cart message displayed | |

### 2C — Wishlist

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-18 | Add product to wishlist | Tap wishlist/heart icon on product detail | Product added to wishlist; icon state updates | |
| EC-19 | View wishlist | Navigate to Wishlist | All wishlisted products listed | |
| EC-20 | Add to cart from wishlist | Tap "Add to Cart" on a wishlist item | Item added to cart; success toast shown | |
| EC-21 | Remove from wishlist | Tap remove on a wishlist item | Item removed from wishlist | |
| EC-22 | Empty wishlist state | No wishlisted products | Empty state shown | |
| EC-23 | Pull to refresh wishlist | Pull down | Wishlist reloads from server | |

### 2D — Checkout & Orders

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-24 | Proceed to checkout | Tap Checkout from cart | Checkout screen loads with cart summary, delivery fee, address selector, payment method | |
| EC-25 | Checkout — default address pre-selected | User has a default address | Default address auto-selected in checkout | |
| EC-26 | Checkout — select different address | Tap address selector → pick another | Selected address updates | |
| EC-27 | Checkout — payment method COD | Select COD | COD selected; order can proceed | |
| EC-28 | Checkout — add note | Enter order note | Note saved and sent with order | |
| EC-29 | Checkout — no address selected | Submit without selecting any address | "Please select an address" error shown | |
| EC-30 | Place order successfully | Complete checkout with address, COD → Place Order | Order success screen shown with order ID | |
| EC-31 | Order success screen | After placing order | Confirmation message and order ID visible | |
| EC-32 | Delivery fee applied | View order total in checkout | Delivery fee (Rs. 450) added to subtotal | |
| EC-33 | View order history | Navigate to Order History | All past orders listed with status, date, total | |
| EC-34 | Paginate order history | Scroll to bottom of order list | Next page of orders loads (load more) | |
| EC-35 | View order details | Tap an order | Full detail: items, shipping address, payment method, status, subtotal, delivery fee, total, note | |
| EC-36 | Order status shown | View order detail | Status (e.g. Pending, Processing, Delivered) visible | |

### 2E — Addresses & Vouchers

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-37 | View saved addresses | Navigate to Addresses | All saved addresses listed | |
| EC-38 | Add new address | Tap Add Address → fill form → Save | New address appears in list | |
| EC-39 | Edit existing address | Tap Edit on an address → update → Save | Address updated | |
| EC-40 | Set default address | Tap Set Default on an address | That address becomes default (marked visually) | |
| EC-41 | Delete address | Delete an address | Address removed from list | |
| EC-42 | View vouchers | Navigate to My Vouchers | All vouchers shown with code, description, expiry | |
| EC-43 | Active voucher display | Voucher not expired or used | Full opacity; copy code available | |
| EC-44 | Expired/used voucher display | Voucher is expired/used | Greyed out; marked visually as expired | |
| EC-45 | Copy voucher code | Tap copy icon on voucher | Code copied to clipboard; feedback shown | |

### 2F — Product Reviews

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| EC-46 | View product reviews | Open product detail page | Review cards shown with rating, comment, reviewer | |
| EC-47 | No reviews state | Product has no reviews | "No reviews yet" or empty state shown | |

---

## 🏥 Module 3 — Vet Finder & Appointment Booking

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| VET-01 | Vet Finder home screen | Navigate to Vet tab | Header banner and radius selector shown | |
| VET-02 | Select search radius | Tap radius options (5, 10, 25, 50, 100 km) | Selected radius updates | |
| VET-03 | Find vets | Tap Find Vets | Navigates to Vet Search Results screen | |
| VET-04 | View vet search results | Search results page loads | Vets listed with name, specialization, rating, reviews, address, distance, open/closed status | |
| VET-05 | Open/closed status badge | View vet card | "Open" or "Closed" badge displayed correctly | |
| VET-06 | View vet detail | Tap a vet card | Vet Details screen opens with full info: name, specialization, clinic address, phone, rating | |
| VET-07 | Call vet from detail | Tap phone number on vet detail | Phone dialer opens with vet's number | |
| VET-08 | Navigate to booking from detail | Tap Book Appointment | Vet Booking screen opens | |
| VET-09 | Booking — date picker | On booking screen, pick a date | Calendar shows and date is selectable (future dates only) | |
| VET-10 | Booking — load time slots | Select a date | Available time slots loaded and grouped into Morning/Afternoon/Evening | |
| VET-11 | Booking — no slots available | Select a date with no slots | Empty state or "No slots available" shown | |
| VET-12 | Booking — select time slot | Tap an available slot | Slot highlighted as selected | |
| VET-13 | Booking — select pet | Choose pet from dropdown | Pet selected for appointment | |
| VET-14 | Booking — no pet selected | Attempt to book without pet | Validation error shown | |
| VET-15 | Booking — no time selected | Attempt to book without time slot | Validation error shown | |
| VET-16 | Confirm appointment | Select date, time, pet → Confirm | Appointment booked; success message shown | |
| VET-17 | View my appointments | Navigate to My Vet Appointments | All appointments listed with vet, pet, date, time, status | |
| VET-18 | Appointment status — Upcoming | Future appointment | Status shows "Upcoming" or equivalent | |
| VET-19 | Appointment status — Completed | Past appointment | Status shows "Completed" | |
| VET-20 | Cancel/manage appointment | Tap on an appointment | Option to cancel or view details available | |

---

## 🥗 Module 4 — Diet Planning (Nutrition)

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| DP-01 | View Nutrition Plans page | Navigate to Nutrition | All existing meal plans for pets listed | |
| DP-02 | Empty plans state | No plans generated | Empty state with CTA to generate a plan | |
| DP-03 | Pull to refresh plans | Pull down on Nutrition page | Plan list reloads | |
| DP-04 | Generate plan — open form | Tap Generate / Add Plan | Diet form dialog opens | |
| DP-05 | Generate plan — select pet | Choose a pet from dropdown | Pet name, breed, age, weight pre-filled or selectable | |
| DP-06 | Generate plan — set activity level | Select Low / Medium / High | Activity level selected | |
| DP-07 | Generate plan — enter disease | Enter health condition or "None" | Field accepts text | |
| DP-08 | Generate plan — enter allergy | Enter allergy or "None" | Field accepts text | |
| DP-09 | Generate plan — submit | Fill all fields → Generate | Plan generated and appears in Nutrition Plans list | |
| DP-10 | Generate plan — missing pet | Submit without selecting pet | Validation error shown | |
| DP-11 | View meal plan details | Tap a plan card | Detail screen opens | |
| DP-12 | Pet info on detail page | View plan details | Pet name, breed, activity level, disease, allergy shown | |
| DP-13 | Nutrition summary visible | View plan details | Calories, protein, fat, carbs, and other nutrition values shown | |
| DP-14 | Daily meal plan breakdown | View plan details | Each meal (breakfast, lunch, dinner, snacks) listed with portions | |
| DP-15 | Warnings displayed | Plan includes warnings | Warning items listed under "Warnings" section | |
| DP-16 | Tips displayed | Plan includes tips | Tips listed under "Tips" section | |
| DP-17 | Export plan as PDF | Tap export/download button | PDF generated and saved/shared from device | |
| DP-18 | Multiple pets — separate plans | Two pets each with a plan | Both plans listed separately, labelled by pet name | |

---

## 🐶 Module 5 — Pet Adoption

### 5A — Browsing & Discovery

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| AD-01 | View Adoption dashboard | Navigate to Adoption tab | Adoptable pets listed with photo, name, breed, species, location, adoption fee | |
| AD-02 | View pet detail | Tap an adoptable pet card | Pet Details page opens with hero image, name, species, breed, age, gender, size, energy level, good with kids/pets, description, color, adoption fee, adoption center | |
| AD-03 | Pet photo gallery | View pet detail | Multiple pet photos viewable if available | |
| AD-04 | Favourite a pet | Tap heart/favourite icon on pet detail | Pet marked as favourite; icon state changes | |
| AD-05 | Unfavourite a pet | Tap favourite icon again | Pet removed from favourites | |
| AD-06 | Share pet | Tap share icon on pet detail | Share sheet opens | |
| AD-07 | Proceed to Apply | Tap "Apply for Adoption" button | Navigates to Adoption Application form | |

### 5B — Advanced Search

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| AD-08 | Open Advanced Search | Tap search/filter option | Advanced Search page opens with Filter and AI Search tabs | |
| AD-09 | Filter tab — species filter | Select Dog / Cat | Results filtered by species | |
| AD-10 | Filter tab — gender filter | Select Male / Female | Results filtered by gender | |
| AD-11 | Filter tab — size filter | Select Small / Medium / Large | Results filtered by size | |
| AD-12 | Filter tab — energy level | Select energy level option | Results filtered accordingly | |
| AD-13 | Filter tab — color | Enter or select color | Results filtered by color | |
| AD-14 | Filter tab — Good with Kids | Toggle "Good with Kids" | Results include only compatible pets | |
| AD-15 | Filter tab — Good with other pets | Toggle "Good with other pets" | Results filtered accordingly | |
| AD-16 | Filter tab — no results | Apply filters with no matching pets | "No pets found" empty state shown | |
| AD-17 | AI Search tab | Switch to AI Search tab | Natural language description input available | |
| AD-18 | AI search — submit description | Enter "I want a calm small dog good with kids" → Search | AI-extracted filters shown; matching pets returned | |
| AD-19 | AI search — detected filters shown | AI search returns results | Detected filter tags displayed (e.g. species: dog, size: small) | |
| AD-20 | AI search — no results | AI search with no matches | Empty state displayed | |
| AD-21 | AI search — error handling | Network failure during AI search | Error message shown; user can retry | |

### 5C — Adoption Application

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| AD-22 | View application form | Navigate to Apply page | Form loads for the selected pet with pet info visible | |
| AD-23 | Living type selection | Select House / Apartment / etc. | Option selected | |
| AD-24 | Has children toggle | Toggle "Has Children" = Yes | Children ages input field appears | |
| AD-25 | Children ages input | Enter ages as comma-separated numbers | Valid ages parsed and submitted | |
| AD-26 | Has other pets toggle | Toggle "Has Other Pets" = Yes | Other pets detail field appears | |
| AD-27 | Activity level selection | Select Low / Moderate / High | Option selected | |
| AD-28 | Experience level selection | Select First-time / Experienced / etc. | Option selected | |
| AD-29 | Work schedule selection | Select Full-time / Part-time / etc. | Option selected | |
| AD-30 | Reason for adoption — required | Leave reason blank → Submit | Validation error shown | |
| AD-31 | Reason for adoption — valid | Enter reason text → Submit | Form proceeds | |
| AD-32 | Additional notes — optional | Leave notes blank → Submit | Submission still proceeds | |
| AD-33 | Submit application — all valid | Fill all required fields → Submit | Success dialog shown: "Application submitted" | |
| AD-34 | Submit application — unauthenticated | Submit without login | "Please log in to submit an adoption application" error shown | |
| AD-35 | Submit application — server error | Simulate server failure | "Failed to submit. Please try again." error shown | |

### 5D — My Applications

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| AD-36 | View my applications | Navigate to My Applications | All submitted applications listed | |
| AD-37 | Application card info | View a card | Pet name, application date, and status visible | |
| AD-38 | Application status — Pending | New application | Status shows "Pending" | |
| AD-39 | Application status — Approved | Approved application | Status shows "Approved" | |
| AD-40 | Application status — Rejected | Rejected application | Status shows "Rejected" | |
| AD-41 | Withdraw application | Tap Withdraw on an application | Confirmation dialog appears | |
| AD-42 | Confirm withdrawal | Confirm in dialog | Application withdrawn; success toast shown; list updated | |
| AD-43 | Cancel withdrawal | Tap Cancel in dialog | Application remains in list unchanged | |
| AD-44 | Empty applications state | No applications submitted | Empty state message shown | |
| AD-45 | Pull to refresh applications | Pull down | Applications list reloads | |
| AD-46 | Unauthenticated access | Open My Applications without login | "Please log in to view your applications" error shown | |

---

## 🔔 Module 6 — Notifications

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| NT-01 | View notifications page | Navigate to Notifications | List of notifications displayed | |
| NT-02 | Unread notification badge | New notification received | Badge count on notifications icon | |
| NT-03 | Appointment reminder notification | Appointment due soon | Notification received with appointment details | |
| NT-04 | Vaccination due notification | Vaccination next-due date approaching | Notification shown | |
| NT-05 | Order status update notification | Order status changes | Notification received with order info | |
| NT-06 | Adoption status update notification | Application status changes | Notification received | |
| NT-07 | Empty notifications state | No notifications | Empty state shown | |
| NT-08 | Tap notification | Tap a notification | Navigates to the relevant page (appointment, order, etc.) | |

---

## 🧭 Module 7 — Navigation & General UX

| TC# | Test Case | Steps | Expected Result | Pass/Fail |
|-----|-----------|-------|-----------------|-----------|
| NAV-01 | Bottom navigation — all tabs | Tap each tab (Home, Shop, Vet, Nutrition, Adoption, Profile) | Each tab navigates to correct page | |
| NAV-02 | Dashboard page loads | Open app after login | Dashboard shows quick links and summary | |
| NAV-03 | Back navigation | Tap back button on any screen | Returns to previous screen without data loss | |
| NAV-04 | Deep link navigation | Navigate via notification deep link | Correct screen opens | |
| NAV-05 | Loading states | Any API call in progress | Loading spinner / skeleton shown | |
| NAV-06 | Error states | API returns error | Error message displayed; retry option available | |
| NAV-07 | Offline / no internet | Disable network → navigate | Informative error or cached content shown | |
| NAV-08 | Responsive layout — small screen | Use on small device | No overflow errors; all content accessible | |
| NAV-09 | Responsive layout — large screen | Use on tablet/large device | Layout scales properly | |

---

## Test Coverage Summary

| Module | Description | Test Count |
|--------|-------------|------------|
| Module 0 | Authentication & Onboarding | 15 |
| Module 1A | User Profile | 12 |
| Module 1B | Pet Profile Management | 17 |
| Module 1C | Vaccinations | 7 |
| Module 1D | Medical Reports & Appointments | 5 |
| Module 1E | AI Symptom Checker & Diagnosis | 17 |
| Module 2 | E-Commerce (Product Discovery, Cart, Wishlist, Checkout, Orders, Addresses, Vouchers, Reviews) | 47 |
| Module 3 | Vet Finder & Appointment Booking | 20 |
| Module 4 | Diet Planning (Nutrition) | 18 |
| Module 5 | Pet Adoption (Browsing, Advanced Search, Application, My Applications) | 39 |
| Module 6 | Notifications | 8 |
| Module 7 | Navigation & General UX | 9 |
| **Total** | | **204** |
