Extension { #name : 'ScaledDecimal' }

{ #category : '*SSW ReStore SQL Entities' }
ScaledDecimal >> writeSQLOn: aStream [

	"We don't want the s postfix"

	self displayOn: aStream
]
