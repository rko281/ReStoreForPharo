Extension { #name : #SSWReStore }

{ #category : #'*SSW ReStore Tests' }
SSWReStore >> simulateReconnect [

	"Simultate a disconnect; reconnect sequence of the receiver, however do not cycle the connection.
	This is to allow data to be preserved by transirent in-memory test databases (e.g. SQLite :memory: mode)"
	
	"Disconnect"
	self
		clearProxyCache;
		clearNextIDCache;
		clearTransaction;
		clearDBTableNames;
		clearStatementCache.
	self class deactivated: self.

	"Reconnect"
	self objectProxyClass isNil ifTrue: [self setDefaultTransactionMode].
	self transactionMutex: Mutex new.
	self class activated: self.
	self persistentSystemClasses do: [ :each | self addClass: each]
]
