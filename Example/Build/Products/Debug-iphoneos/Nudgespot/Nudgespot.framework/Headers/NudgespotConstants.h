//
//  NudgespotConstants.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//


//  PROD CONFIG

static NSString * REST_API_ENDPOINT = @"https://api.boomtrain.net/201507";

static NSString *const TRACK_API_ENDPOINT = @"https://track.nudgespot.com/android/message_events";

static NSString *const CONTACT_TYPE_EMAIL = @"email";


static NSString *const CONTACT_TYPE_PHONE = @"phone";

//static NSString *const CONTACT_TYPE_ANDROID_REGISTRATION_ID = @"android_registration_id";

static NSString *const CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID = @"ios_gcm_registration_id";

static NSString *const CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID_ANON = @"ios_gcm_registration_id_anon";


static NSString *const SHARED_APNS_TOKEN_TYPE = @"NudgespotAPNSTokenType";

static NSString *const SHARED_PREFS_NAME = @"com.nudgespot.gcmclient.prefs";

static NSString *const SHARED_PROP_SUBSCRIBER_UID = @"nudgespot::subscriber_uid";

static NSString *const SHARED_PROP_REGISTRATION_ID = @"nudgespot::registration_id";

static NSString *const SHARED_PROP_REGISTRATION_SENT = @"nudgespot::registration_sent";

static NSString *const iOS_VIEWCONTROLLER = @"ios_view_controller";

static NSString *const SHARED_PROP_APP_VERSION = @"nudgespot::app_version";

static NSString *const SHARED_PROP_DEVICE_VERSION = @"version";

static NSString *const SHARED_PROP_ANON_ID = @"anon_Id";

static NSString *const SHARED_PROP_IS_ANON_USER_EXISTS = @"isAnonymousUserExits";

static NSString *const SUBSCRIBER_CREATE_PATH = @"subscribers";

static NSString *const SUBSCRIBER_FIND_PATH = @"subscribers.json?uid=";

static NSString *const SUBSCRIBER_IDENTIFY = @"subscribers/identify";

static NSString *const VISITOR_IDENTIFY = @"accounts/identify_visitor";

static NSString *const ACTIVITY_CREATE_PATH = @"activities";


static NSString *const iOS_USER = @"ios_user";


static NSString *const KEY_iOS_OS_VERSION = @"ns_os_version";

static NSString *const KEY_DEVICE_MODEL = @"ns_device_model";

static NSString *const KEY_DEVICE_MANUFACTURER = @"ns_device_manufacturer";


static NSString *const SOURCE_LIB = @"source_lib";


//static NSString *const ACCOUNTS_SDK_CONFIG = @"accounts/sdk_config";


static NSString *const VISITOR_REGISTRATION = @"visitors/register";

static NSString *const KEY_RESOURCE_LOCATION = @"href";

static NSString *const KEY_VISITOR_UID = @"anon_id";

static NSString *const KEY_VISITOR = @"visitor";

static NSString *const KEY_VISITOR_TYPE = @"type";

static NSString *const KEY_VISITOR_TYPE_iOS = @"ios";

static NSString *const KEY_VISITOR_PROPERTIES = @"properties";

static NSString *const KEY_VISITOR_DEVICE_INFO = @"device_info";


static NSString *const KEY_ACTIVITY = @"activity";

static NSString *const KEY_ACTIVITY_NAME = @"event";

static NSString *const KEY_ACTIVITY_TIMESTAMP = @"timestamp";

static NSString *const KEY_ACTIVITY_SUBSCRIBER = @"subscriber";

static NSString *const KEY_ACTIVITY_PROPERTIES = @"properties";


static NSString *const KEY_SUBSCRIBER = @"subscriber";

static NSString *const KEY_SUBSCRIBER_RES_URL = @"href";

static NSString *const KEY_SUBSCRIBER_UID = @"uid";

static NSString *const KEY_SUBSCRIBER_ID = @"id";

static NSString *const KEY_SUBSCRIBER_ACCOUNTID = @"account_id";

static NSString *const KEY_SUBSCRIBER_NAME = @"name";

static NSString *const KEY_FIRST_NAME = @"first_name";

static NSString *const KEY_LAST_NAME = @"last_name";

static NSString *const KEY_DISPLAY_NAME = @"display_name";

static NSString *const KEY_DISPLAY_EMAIL = @"display_email";

static NSString *const KEY_SIGNED_UP_AT = @"signed_up_at";

static NSString *const KEY_SUBSCRIPTION_STATUS = @"subscription_status";


static NSString *const KEY_SUBSCRIBER_PROPERTIES = @"properties";

static NSString *const KEY_PROPERTIES_GENDER = @"gender";

static NSString *const KEY_PROPERTIES_LASTSEEN = @"last_seen";

static NSString *const KEY_PROPERTIES_PLAN = @"plan";


static NSString *const KEY_CONTACT = @"contacts";

static NSString *const KEY_CONTACT_TYPE = @"contact_type";

static NSString *const KEY_CONTACT_VALUE = @"contact_value";

static NSString *const KEY_CONTACT_SUBSCRIPTION_STATUS = @"subscription_status";


static NSString *const CURRENT_DATEFORMAT = @"yyyy-MM-dd'T'HH:mm:SS.SSS'Z'";


static NSString *const KEY_ERROR = @"error";

static NSString *const KEY_ERROR_TYPE = @"type";

static NSString *const KEY_ERROR_MESSAGE = @"message";


static NSString *const KEY_MESSAGEID = @"message_id";

static NSString *const KEY_EVENT = @"event";

static NSString *const KEY_TIMESTAMP = @"timestamp";



