//  Macro.h
//  Eventnoire-Attendee
//  Created by Aiman Akhtar on 23/03/17.
//  Copyright © 2017 com.mobiloitte. All rights reserved.

#ifndef Macro_h
#define Macro_h

#define TextField(tag)             (UITextField*)[self.view viewWithTag:tag]
#define TextView(tag)              (UITextView*)[self.view viewWithTag:tag]
#define Button(tag)                (UIButton *)[self.view viewWithTag:tag]

#define windowWidth                 [UIScreen mainScreen].bounds.size.width
#define windowHeight                [UIScreen mainScreen].bounds.size.height

#define KNSLOCALIZEDSTRING(key)     NSLocalizedString(key, nil)

#define APPDELEGATE                 (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define mainStoryboard              [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define storyboardForName(X)        [UIStoryboard storyboardWithName:X bundle:nil]

#define NSUSERDEFAULT               [NSUserDefaults standardUserDefaults]

#define AppColor                    [UIColor colorWithRed:72.0/255.0f green:176.0/255.0f blue:254.0/255.0f alpha:1.0f]
#define AppFont(X)                  [UIFont fontWithName:@"OpenSans" size:X]

#define IS_OS_8_OR_LATER       ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

//log label

#define LOG_LEVEL           1

#define LogInfo(frmt, ...)                 if(LOG_LEVEL) NSLog((@"%s" frmt), __PRETTY_FUNCTION__, ## __VA_ARGS__);

#define RGBCOLOR(r,g,b,a)               [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define TRIM_SPACE(str)                 [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]


//Device Check
#define SCREEN_MAX_LENGTH (MAX(windowWidth, windowHeight))
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

static NSString *blank_Name                          = @"*Please enter name.";
static NSString *blank_FirstName                     = @"*Please enter first name.";
static NSString *blank_LastName                      = @"*Please enter last name.";
static NSString *blank_CountryCode                      = @"*Please select country code.";

static NSString *blank_Email                         = @"*Please enter email.";
static NSString *blank_Password                      = @"*Please enter password.";
static NSString *blank_Phone                         = @"*Please enter phone number.";
static NSString *blank_Confirm_Password              = @"*Please enter confirm password.";

static NSString *blank_OTP                           = @"*Please enter OTP.";
static NSString *blank_Email_Mobile                  = @"*Please enter email/mobile no.";
static NSString *blank_Event                         = @"*Please select event type.";
static NSString *blank_Search_Event                  = @"*Please enter event location.";
static NSString *blank_Event_Date                    = @"*Please select event date.";
static NSString *blank_Event_Time                    = @"*Please select event time.";
static NSString *invalid_Event_Time                    = @"*Please select valid event time.";

static NSString *blank_Event_Detail                  = @"*Please enter event detail.";

static NSString *valid_Email                         = @"*Please enter a valid email.";
static NSString *valid_FirstName                     = @"*Please enter a valid first name.";
static NSString *valid_Otp                           = @"*Please enter valid otp.";
static NSString *valid_Phone                         = @"*Please enter a valid phone number";
static NSString *valid_Password                      = @"*Password must be of atleast 8 characters.";
static NSString *new_Password                      = @"*Please enter new password.";
static NSString *valid_New_Password                      = @"*New password must be of atleast 8 characters.";

static NSString *password_Confirm_Password_Not_Match = @"*Please enter correct password.";
static NSString *valid_MobileNumber                  = @"*Phone number must be of 10 digits.";
static NSString *no_event                = @"No event found.";
static NSString *no_current_location                = @"*Please select location.";


//Service Name
static NSString *loginApi                                 = @"login";
static NSString *signUpApi                               = @"signup";
static NSString *forgotPasswordApi                  = @"forgot_password";
static NSString *resendOTPApi                         = @"send_otp";
static NSString *logoutApi                                = @"logout";
static NSString *changePasswordApi                  = @"change_password";
static NSString *verifyOTPApi                           = @"verify_otp";
static NSString *infoPagesApi                          = @"static_content";
static NSString *socialLoginApi                        = @"social_login";
static NSString *pushSettingApi                         = @"pushSetting";
static NSString *getInterestListApi                           = @"get_myinterest";
static NSString *sendSelectedInterestsApi                 = @"set_myinterest";
static NSString *updateNotificationApi            = @"update_settings";
static NSString *eventListApi            = @"events_list";
static NSString *myEventListApi            = @"my_events_list";
static NSString *setActionApi            = @"set_actions";
static NSString *updateProfileApi            = @"update_profile";
static NSString *setNotificationCountApi            = @"notification_count";
static NSString *createToDoApi                          = @"add_to_do";
static NSString *toDoListApi                               = @"get_to_do";
static NSString *eventListForToDoApi                               = @"attendee_event_list";
static NSString *resetPassswordAPI                    = @"reset_password";
static NSString *getNotificationAPI                    = @"get_notification";
static NSString *bookEventApi                  = @"book_event";
static NSString *getCustomerTokenAPI                    = @"getCustomerToken";
static NSString *bookEventPaidAPI                    = @"book_event";
static NSString *book_event_infoAPI                    = @"book_event_info";
static NSString *my_events_listAPI                    = @"my_events_list";
static NSString *makePaymentApi                    = @"makePayment";
static NSString *make_paymentAPi                    = @"make_payment";

static NSString *ticketPass                    = @"event_pkpass";

//API Keys
static NSString *pResponseCode                    = @"response_code";
static NSString *pResponseMessage               = @"message";
static NSString *pDeviceType                        = @"deviceType";
static NSString *pDeviceToken                      = @"deviceToken";
static NSString *pUserType                           = @"userType";
static NSString *pUserID                               = @"userId";
static NSString *pEmailID                             = @"email";
static NSString *pPassword                           = @"password";
static NSString *pUserDetail                          = @"data";
static NSString *pPhoneNumber                     = @"phoneNumber";
static NSString *pFirstName                           = @"firstName";
static NSString *pProfilePic                            = @"profilePicture";
static NSString *pLastName                            = @"lastName";
static NSString *pLogInType                            = @"socialType";
static NSString *pLogInTypeUpdate                            = @"loginType";


static NSString *pNotificationId                           = @"notificationId";
static NSString *pSenderId                          = @"senderId";
static NSString *pReceiverId                         = @"receiverId";
static NSString *pNotificationMessage                       = @"notificationMessage";
static NSString *pNotificationType                       = @"notificationType";


static NSString *pIsPhoneNumberVerify            = @"isPhoneNumberVerify";
static NSString *pIsAnouncement                     = @"isAnouncement";
static NSString *pIsFriendUpdate                     = @"isFriendUpdate";
static NSString *pOTPNumber                          = @"otpNumber";
static NSString *pSocialID                               = @"socialId";
static NSString *pContentType                         = @"contentType";
static NSString *pContent                                = @"content";
static NSString *pSocialType                             = @"socialType";
static NSString *pUserName                              = @"userName";
static NSString *pToken                                    = @"token";
static NSString *pEventName                               = @"eventName";
static NSString *pEventLocation                            = @"eventLocation";
static NSString *pEventDate                                  = @"eventDate";
static NSString *pEventTime                                 = @"eventTime";
static NSString *pEventDetail                                = @"eventDetail";
static NSString *pOldPassword                               = @"oldPassword";
static NSString *pNewPassword                               = @"newPassword";
static NSString *iSTutorialSeen                          = @"iSTutorialSeen";
static NSString *remeberMeLogin                         = @"remeberMeLogin";
static NSString *remeberMePassword                         = @"remeberMePassword";
static NSString *pLoginInfo                     = @"loginInfo";
static NSString *pIsRemember                     = @"isRemember";
static NSString *pInterestData                     = @"interests";
static NSString *pEventId                     = @"eventId";
static NSString *pEventDateTime                    = @"eventDateTime";
static NSString *pOtp                    = @"otp";
static NSString *pStripe_token                    = @"stripe_token";


static NSString *pTransactionNonce                    = @"payment_nonce";
static NSString *pID                                                = @"id";
static NSString *pCategoryName                            = @"category_name";
static NSString *pIsSelected                                   = @"is_selected";
static NSString *pImageURL                                    = @"image_url";
static NSString *pCategories                                     = @"categories";
static NSString *pAuthorization                                     = @"Authorization";
static NSString *pTitle                                           = @"title";
static NSString *pStartDate                                     = @"start_date";
static NSString *pEndDate                                     = @"end_date";
static NSString *pType                                           = @"type";
static NSString *pVenueName                                     = @"venue_name";
static NSString *pAddress                                     = @"address";
static NSString *pAddress2                                     = @"address_2";
static NSString *pCity                                    = @"city";
static NSString *pState                                    = @"state";
static NSString *pZipCode                                    = @"pZipCode";
static NSString *pCountryCode                                    = @"country_code";
static NSString *pLatitude                                    = @"latitude";
static NSString *pLongitude                                    = @"longitude";
static NSString *pEventType                                 = @"event_name";
static NSString *pTicketType                                    = @"ticket_type";
static NSString *pTicketAmount                                    = @"ticket_amounts";
static NSString *pIsBookmarked                                    = @"is_bookmarked";
static NSString *pIsFavourite                                    = @"is_favourite";
static NSString *pDescription                                    = @"description";
static NSString *pEvents                                    = @"events";
static NSString *pShareEvent                                    = @"shareEvent";
static NSString *pCountryName                                    = @"ticket_country";
static NSString *pAmountCurrency                                    = @"ticket_currency";
static NSString *pMaximumPageNumber                                    = @"maximumPages";
static NSString *pTotalNumberOfRecord                                    = @"total_no_records";
static NSString *pName                                    = @"name";
static NSString *pTotalSeats                                    = @"total_seats";
static NSString *pRemainingSeats                                    = @"remaining_seats";
static NSString *pAmount                                    = @"amount";
static NSString *pStatus                                    = @"status";
static NSString *pTicketInfo                                    = @"tickets_info";
static NSString *pDistance                                    = @"distance";
static NSString *pEventID                                    = @"event_id";
static NSString *pFlaggingType                                    = @"flagging_type";
static NSString *pActions                                    = @"actions";
static NSString *pPrefix                                    = @"prefix";
static NSString *pJobTitle                                    = @"job_title";
static NSString *pOrganisation                                    = @"organization";
static NSString *pTicketQuantity                                    = @"ticket_quantity";
static NSString *pPrefixPayment                                     = @"prefix";
static NSString *pJobTitlePayment                                     = @"job_title";
static NSString *pOrganizationPayment                                    = @"organization";
static NSString *pTicket_typePayment                                   = @"ticket_type";
static NSString *pTicket_amountPayment                                  = @"ticket_amount";
static NSString *pTicket_quantityPayment                                  = @"ticket_quantity";
static NSString *pTicket_type_idPayment                                  = @"ticket_type_id";
static NSString *pEvent_ticket_id                                 = @"event_ticket_id";
static NSString *pTicket_details                              = @"ticket_details";
static NSString *pEvent_details                              = @"event_details";
static NSString *pSearch_event                             = @"search_event";
static NSString *pInterest_id                            = @"category_id";
static NSString *pNo_of_ticket                            = @"no_of_ticket";
static NSString *pBookingID                            = @"booking_id";
static NSString *pTotalAmount                            = @"total_amount";
static NSString *pClientToken                            = @"clientToken";
static NSString *pTransactionID                            = @"transaction_id";
static NSString *pAction                                    = @"action";
static NSString *pDistanceIn                                    = @"distance_in";
static NSString *pFbFriendList              = @"facebook_friend_id";
static NSString *pCreatedTime                                    = @"createdTime";
static NSString *pEventTitle                                   = @"eventTitle";
static NSString *pFirst_name                                  = @"first_name";
static NSString *pLast_name                                  = @"last_name";
static NSString *pQr_code_url                                  = @"qr_code_url";
static NSString *pDes                                 = @"description";
static NSString *pPagination                            = @"pagination";
static NSString *pPageNumber                            = @"page_number";
static NSString *pMaximumPages                            = @"maximumPages";
static NSString *pTotalNumberOfRecords                            = @"total_no_records";
static NSString *pEventPKPass                            = @"event_pkpass_url";


#endif /* Macro_h */
