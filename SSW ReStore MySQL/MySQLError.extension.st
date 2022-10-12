Extension { #name : #MySQLError }

{ #category : #'*SSW ReStore MySQL' }
MySQLError >> asSSWMySQLResultSet [

	self signalError
]

{ #category : #'*SSW ReStore MySQL' }
MySQLError >> signalError [

	MySQLDriverError signal: message with: errNo
]
