Class {
	#name : #Translate,
	#superclass : #Object,
	#category : #Feedbackinator
}

{ #category : #accessing }
Translate class >> toNL [
	"take 'self contents' (from Lepiter page) and translate to (NL) Dutch"

	| message client text |
	client := GtOllamaClient new.	"Yes: Ollama for now"
	text := 1.

	message := 'Please translate the following text to Dutch: """' , 42 , '"""'.
	client sendMessage: message.
	client
]

{ #category : #accessing }
Translate class >> toNL: aText [
	"take 'self contents' (from Lepiter page) and translate to (NL) Dutch"

	| message client |
	client := GtOllamaChat new model: 'llama3.1'.	"Yes: Ollama for now"

	message := 'Please translate the following text to Dutch, show only the result of the translation, without explanation: """' , aText asString , '"""'.
	client sendMessage: message.
	^ client
]
