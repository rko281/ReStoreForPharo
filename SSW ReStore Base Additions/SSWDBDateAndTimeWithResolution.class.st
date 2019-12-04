"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBDateAndTimeWithResolution,
	#superclass : #SSWDBClassWithInfo,
	#instVars : [
		'resolution'
	],
	#category : #'SSW ReStore Base Additions'
}

{ #category : #initializing }
SSWDBDateAndTimeWithResolution >> beMicrosecondResolution [

	self resolution: 6
]

{ #category : #initializing }
SSWDBDateAndTimeWithResolution >> beMillisecondResolution [

	self resolution: 3
]

{ #category : #constants }
SSWDBDateAndTimeWithResolution >> infoClass [

	^DateAndTime
]

{ #category : #accessing }
SSWDBDateAndTimeWithResolution >> resolution [ 

	"resolution is the number of digits after the decimal point following seconds:
	 - 0 for seconds resolution
	 - 3 for milliseconds resolution
	 - 6 for microseconds resolution etc."

	^resolution
]

{ #category : #accessing }
SSWDBDateAndTimeWithResolution >> resolution: anInteger [

	"resolution is the number of digits after the decimal point following seconds:
	 - 0 for seconds resolution
	 - 3 for milliseconds resolution
	 - 6 for microseconds resolution etc."

	resolution := anInteger
]
