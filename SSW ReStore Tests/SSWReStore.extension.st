Extension { #name : #SSWReStore }

{ #category : #'*SSW ReStore Tests' }
SSWReStore >> simulateReconnect [

	"Simultate a disconnect; reconnect sequence of the receiver, however do not cycle the connection.
	This is to allow data to be preserved by transirent in-memory test databases (e.g. SQLite :memory: mode)"
	
	self attachTo: self detach
]
