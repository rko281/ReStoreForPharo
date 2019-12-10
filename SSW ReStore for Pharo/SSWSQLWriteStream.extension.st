Extension { #name : #SSWSQLWriteStream }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLWriteStream >> parameterizedColumnsFor: aStatement [

	| parameterizedColumns |

	parameterizedColumns := Array new: self parameterizedFields size.

	self parameterizedFields keysAndValuesDo: [ :index :field | parameterizedColumns at: index put: (field asParameterColumn: index for: aStatement)].

	^parameterizedColumns
]
