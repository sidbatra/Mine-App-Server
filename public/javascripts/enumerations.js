// App wide enumerations

// Valid hash fragments for the user show page
//
Denwen.UserShowHash = {
  Owns        : 'owns',
  Wants       : 'wants',
  Collections : 'uses'
}

// Callbacks used across the application
//
Denwen.Callback = {
  ProductsLoaded        : 'productsLoaded',
  UsersListLoaded       : 'usersListLoaded',
  StoresLoaded          : 'storesLoaded',
  CollectionsListLoaded : 'collectionsListLoaded'
}

// Callbacks for the uploader partial
//
Denwen.Callbacks.Uploader = {
  FileSelected        : 'fileSelected',
  FileUploadError     : 'fileUploadError',
  FileUploadDone      : 'fileUploadDone',
  FileUploadProgress  : 'fileUploadProgress'
}

Denwen.ProductQueryType  = {
  Text  : 'text',
  URL   : 'url'
}
