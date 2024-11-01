//
//  MessageCard.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//

import SwiftUI
import MarkdownUI
import UniformTypeIdentifiers

struct MessageCard: View {
    var message: MessageModel
    var isLastMessage : Bool = false
    @Binding var isGenerating : Bool
    let onRegenerate: () -> Void

    var body: some View {
        VStack()
        {
            if message.isUserMessage
            {
                let output = (message.content as! String)
                HumanMessageCard(message: output)
            }else
            {
                let output = (message.content as! String)
                BotMessageCard(message: output, isLastMessage : isLastMessage, isGenerating: $isGenerating, onRegenerate: onRegenerate)
            }
        }
        .frame(maxWidth: .infinity,alignment: message.isUserMessage ? .trailing : .leading)
        .padding(.trailing, message.isUserMessage ? 0 : 10)
        .padding(.leading, message.isUserMessage ? 10 : 0)
        .padding(.vertical, 4)
        
    }
}

struct HumanMessageCard : View
{
    var message : String = ""
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var body: some View{
        ZStack
        {
            if message.starts(with: Constants.START_WEB_LINK)
            {
                HStack
                {
                    Image("Link")
                        .resizable().scaledToFill()
                        .padding(3)
                        .frame(width: 30, height: 30)
                        .foregroundColor( .text_color)
                        .padding(.trailing, 10)
                    
                    Text("web_page".localize(language) + " (")
                        .modifier(UrbanistFont(.bold, size: 16))
                        .foregroundColor(.text_color)
                    Text(message.split(separator: "||")[1])
                        .modifier(UrbanistFont(.bold, size: 16))
                        .foregroundColor(.blue) // Apply blue color to this part
                    Text(")")
                        .modifier(UrbanistFont(.bold, size: 16))
                        .foregroundColor(.text_color)
                        .multilineTextAlignment(.leading)
                    
                }.lineLimit(1)
                    .truncationMode(.tail)
                    .padding(10).background(Color.gray_color)
                    .cornerRadius(99).padding(10)
            }else
            {
                Text(message).padding(.vertical, 12).padding(.horizontal, 18).multilineTextAlignment(.trailing).foregroundColor(.white)  .modifier(UrbanistFont(.semi_bold, size: 16))
            }
            
        }.background(
            Color.green_color
        ).cornerRadius(13, corners: [.topLeft, .bottomRight, .bottomLeft]).cornerRadius(5, corners: [.topRight])
        
    }
}

struct BotMessageCard : View
{
    var message : String = ""
    var isLastMessage : Bool = false
    @State private var isShare = false
    @Binding var isGenerating : Bool
    let onRegenerate: () -> Void

    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    @State var showSuccessToast : Bool = false

    @State private var isShowingPDFViewer = false  // PDFViewer sheet의 상태를 제어하는 변수
      
    var body: some View{
        
        ZStack
        {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Markdown(message)
                    .multilineTextAlignment(.leading).foregroundColor(.text_color)
                    .markdownTextStyle(\.text)
                {
                    FontFamily(.custom("Urbanist-SemiBold"))
                    FontSize(16)
                }
                .markdownBlockStyle(\.codeBlock) { configuration in
                    
                    configuration.label
                        .padding()
                        .markdownTextStyle {
                            FontFamilyVariant(.normal)
                            BackgroundColor(nil)
                            ForegroundColor(.white)
                        }.foregroundColor(.white).modifier(UrbanistFont(.bold, size: 25))
                        .background( RoundedRectangle(cornerRadius: 8)
                            .fill(Color.code_background))
                }
                
                if  !isGenerating && isLastMessage {
                
                    ScrollView(.horizontal, showsIndicators: false) {
                        Spacer().frame(height: 20)
                        HStack(spacing: 10){
                            
                            
                            HStack
                            {
                                
                                Button {
                                    // Button을 클릭했을 때 PDFViewer sheet를 띄움
                                                  isShowingPDFViewer.toggle()
                                } label: {
                                 
                                        Text("Fill Application").modifier(UrbanistFont(.semi_bold, size: 12)).multilineTextAlignment(.leading)
                                            .foregroundColor(Color.green_color)
                                    }.padding(.vertical, 5).padding(.horizontal,9).background(Color.message_background).cornerRadius(99)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 99)
                                                .stroke(Color.green_color, lineWidth: 1.5)
                                        )
                                }.buttonStyle(BounceButtonStyle())
                            // sheet를 사용하여 PDFViewer 화면을 띄움
                                      .sheet(isPresented: $isShowingPDFViewer) {
                                          TranslateView()
                                      }
                            Button {
                                if let url = URL(string: "https://www.hikorea.go.kr/Main.pt") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                    HStack(spacing: 10){
            
                                        
                                        Text("HiKorea Website".localize(language)).modifier(UrbanistFont(.semi_bold, size: 12)).multilineTextAlignment(.leading)
                                            .foregroundColor(Color.green_color)
                                    }.padding(.vertical, 5).padding(.horizontal,9).background(Color.message_background).cornerRadius(99)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 99)
                                                .stroke(Color.green_color, lineWidth:  1.5)
                                        )
                                }.buttonStyle(BounceButtonStyle())
                               
                                
                                Button {
                                    
                                    //네이버 지도
                                    if let url = URL(string: Constants.RATE) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 10){
                                
                                        Text("Office Location".localize(language)).modifier(UrbanistFont(.semi_bold, size: 12)).multilineTextAlignment(.leading)
                                            .foregroundColor(Color.green_color)
                                    }.padding(.vertical, 5).padding(.horizontal,9).background(Color.message_background).cornerRadius(99)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 99)
                                                .stroke(Color.green_color, lineWidth:  1.5)
                                        )
                                }.buttonStyle(BounceButtonStyle())
                            }

                            
                        
                        
                    }.padding(3)

                }else if !isLastMessage {
                    Spacer().frame(height: 20)
                    Button {
                        UIPasteboard.general.setValue(message,
                                                      forPasteboardType: UTType.plainText.identifier)
                        
                        showSuccessToast = true
                    } label: {
                        HStack(spacing: 10){
                            Image("Copy")
                                .resizable().scaledToFill()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.text_color)
                            
                            
                            Text("copy".localize(language)).modifier(UrbanistFont(.semi_bold, size: 12)).multilineTextAlignment(.leading)
                                .foregroundColor(Color.text_color)
                        }.padding(.vertical, 5).padding(.horizontal,9).background(Color.message_background).cornerRadius(99)
                            .overlay(
                                RoundedRectangle(cornerRadius: 99)
                                    .stroke(Color.text_color, lineWidth:  1.5)
                            )
                    }.buttonStyle(BounceButtonStyle())
                 
                    
                }
            }.padding(.vertical, 12).padding(.horizontal, 18)
            
            
            
            
        }.background(
            Color.message_background
        ).cornerRadius(13, corners: [.topRight, .bottomRight, .bottomLeft]).cornerRadius(5, corners: [.topLeft])
//            .contextMenu {
//                Button {
//                    UIPasteboard.general.setValue(message,
//                                                  forPasteboardType: UTType.plainText.identifier)
//                    
//                } label: {
//                    Label("copy".localize(language), systemImage: "doc.on.doc")
//                }
//                
//                Button {
//                    isShare = true
//                    
//                } label: {
//                    Label("share".localize(language), systemImage: "square.and.arrow.up")
//                }
//            }
        .background(SharingViewController(isPresenting: $isShare) {
                let url = message
                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                // For iPad
                if UIDevice.current.userInterfaceIdiom == .pad {
                    av.popoverPresentationController?.sourceView = UIView()
                }
                
                av.completionWithItemsHandler = { _, _, _, _ in
                    isShare = false // required for re-open !!!
                }
                return av
            })
            .popup(isPresented: $showSuccessToast) {
                HStack(alignment: .center){
                    
                    Text("copied_successfully".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                        .foregroundColor(Color.text_color)
                    
                }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                    .frame(maxWidth: .infinity,alignment : .center).background(Color.green_color)
                
                
            } customize: {
                $0
                    .type (.toast)
                    .position(.top)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .dragToDismiss(true)
            }
        
        
        
    }
}

struct SharingViewController: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    var content: () -> UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: nil)
        }
    }
}



struct MessageCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            MessageCard(message: MessageModel(content: """

---
__Advertisement :)__

- __[pica](https://nodeca.github.io/pica/demo/)__ - high quality and fast image
  resize in browser.
- __[babelfish](https://github.com/nodeca/babelfish/)__ - developer friendly
  i18n with plurals support and easy syntax.

You will like those projects!

---

# h1 Heading 8-)
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading


## Horizontal Rules

___

---

***


## Typographic replacements

Enable typographer option to see result.

(c) (C) (r) (R) (tm) (TM) (p) (P) +-

test.. test... test..... test?..... test!....

!!!!!! ???? ,,  -- ---

"Smartypants, double quotes" and 'single quotes'


## Emphasis

**This is bold text**

__This is bold text__

*This is italic text*

_This is italic text_

~~Strikethrough~~


## Blockquotes


> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.


## Lists

Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa


1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`

Start numbering with offset:

57. foo
1. bar


## Code

Inline `code`

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

``` js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

## Tables

| Option | Description |
| ------ | ----------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

Right aligned columns

| Option | Description |
| ------:| -----------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |


## Links

[link text](http://dev.nodeca.com)

[link with title](http://nodeca.github.io/pica/demo/ "title text!")

Autoconverted link https://github.com/nodeca/pica (enable linkify to see)


## Images

![Minion](https://octodex.github.com/images/minion.png)
![Stormtroopocat](https://octodex.github.com/images/stormtroopocat.jpg "The Stormtroopocat")

Like links, Images also have a footnote style syntax

![Alt text][id]

With a reference later in the document defining the URL location:

[id]: https://octodex.github.com/images/dojocat.jpg  "The Dojocat"


## Plugins

The killer feature of `markdown-it` is very effective support of
[syntax plugins](https://www.npmjs.org/browse/keyword/markdown-it-plugin).


### [Emojies](https://github.com/markdown-it/markdown-it-emoji)

> Classic markup: :wink: :crush: :cry: :tear: :laughing: :yum:
>
> Shortcuts (emoticons): :-) :-( 8-) ;)

see [how to change output](https://github.com/markdown-it/markdown-it-emoji#change-output) with twemoji.


### [Subscript](https://github.com/markdown-it/markdown-it-sub) / [Superscript](https://github.com/markdown-it/markdown-it-sup)

- 19^th^
- H~2~O




++Inserted text++



==Marked text==


### [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.


### [Definition lists](https://github.com/markdown-it/markdown-it-deflist)

Term 1

:   Definition 1
with lazy continuation.

Term 2 with *inline markup*

:   Definition 2

        { some code, part of Definition 2 }

    Third paragraph of definition 2.

_Compact style:_

Term 1
  ~ Definition 1

Term 2
  ~ Definition 2a
  ~ Definition 2b


### [Abbreviations](https://github.com/markdown-it/markdown-it-abbr)

This is HTML abbreviation example.

It converts "HTML", but keep intact partial entries like "xxxHTMLyyy" and so on.

*[HTML]: Hyper Text Markup Language

### [Custom containers](https://github.com/markdown-it/markdown-it-container)

::: warning
*here be dragons*
:::

""", type: .text, isUserMessage: false, conversationId: "123"), isGenerating: .constant(false), onRegenerate: {})
        }
    }
}
