Extension { #name : #MySQLError }

{ #category : #'*SSW ReStore MySQL' }
MySQLError >> asSSWMySQLResultSet [

	MySQLDriverError signal: message with: errNo
]
