Extension { #name : 'MySQLError' }

{ #category : '*SSW ReStore MySQL' }
MySQLError >> rowsAffected [ 

	^0
]

{ #category : '*SSW ReStore MySQL' }
MySQLError >> signalError [

	MySQLDriverError signal: message with: errNo
]
