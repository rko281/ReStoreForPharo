Extension { #name : #SSWDBScaledDecimalWithInfo }

{ #category : #'*SSW ReStore SQL Entities' }
SSWDBScaledDecimalWithInfo >> writeSQLTypeOn: aStream  using: anSQLDialect [

	"Form is something like DECIMAL(precision,scale)"

	| actualPrecision |

	self precision isNil 
		ifTrue: [actualPrecision := 15]
		ifFalse: [actualPrecision := self precision].

	aStream nextPutAll: (anSQLDialect decimal expandMacrosWith: actualPrecision with: self scale)
]
