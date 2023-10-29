# **iOS Developer Test**

## 👀  Assignment

Create a tiny app from scratch where users can pick a lesson from a list and watch it in the details view. 

Also they have to be able to download and watch the lesson when there's no internet connection.

---

### **Timeline:**

🕑  Expect to spend ~12+ hours

---

### **Tools:**

**🔨**  Xcode

**🔨**  CocoaPods or Swift package manager

**🔨**  Combine

---

### Resources:

📷  **[API endpoint to fetch the list of lessons](https://iphonephotographyschool.com/test-api/lessons)**

---

### 📱 **Views**

Lessons list screen:

- Show title “Lessons”
- Implement the lesson list screen using SwiftUI
- Show a thumbnail image and name for each lesson
- List of lessons has to be fetched when opening the application (from URL or local cache when no connection)

Lesson details screen:

- Implement the lessons details screen programmatically using UIKit
- Show video player
- Show a “Download” button to start download for offline viewing
- Show a “Cancel download” and progress bar when video is downloading
- Show lesson title
- Show lesson description
- Show a “Next lesson” button to play next lesson from the list
- Show video in full screen when app rotates to landscape

---

### 🖼 **Design**

The design has to closely match the following screenshots and be locked to portrait mode.

![Design](https://ipsmedia.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb9fd02c6-f567-4e17-8bb0-27e1b07f33a6%2FiOS-design.png?table=block&id=5743fac0-7002-409a-8364-eede144c4a9a&spaceId=18c2b86f-5f00-4ff1-baf7-6be563e77c7d&width=2000&userId=&cache=v2)

### 📎 **Additional details**

- Develop the application using:
    - Xcode
    - CocoaPods or Swift package manager
    - Combine
- Try to use as few 3rd party libraries as possible.
- The application has to work offline with a cached list of the lessons.
- The API endpoint to fetch the list of lessons is
    - https://iphonephotographyschool.com/test-api/lessons

---

### 📝 **Testing**

Write unit and UI automated tests with XCTest. 

Tests have to be meaningful and comprehensive and cover all important functionality of the app.
