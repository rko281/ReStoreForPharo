Class {
	#name : #Utf8String,
	#superclass : #String,
	#category : #Wolphin
}

{ #category : #'instance creation' }
Utf8String class >> fromByteArray: aByteArray [

	^UTF8TextConverter default convertFromSystemString: aByteArray asString
]
