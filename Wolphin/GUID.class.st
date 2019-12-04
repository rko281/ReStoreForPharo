Class {
	#name : #GUID,
	#superclass : #UUID,
	#type : #bytes,
	#category : #Wolphin
}

{ #category : #'instance creation' }
GUID class >> fromString: aString [

	^super fromString: (aString allButFirst allButLast)
]
