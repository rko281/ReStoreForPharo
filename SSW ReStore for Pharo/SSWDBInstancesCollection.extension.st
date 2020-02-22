Extension { #name : #SSWDBInstancesCollection }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBInstancesCollection >> errorNotFound: anObject [
	"Raise a NotFound exception."

	NotFound signalFor: anObject
]
