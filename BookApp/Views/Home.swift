//
//  Home.swift
//  BookApp
//
//  Created by Azmat Ali Akhtar on 17/04/2023.
//

import SwiftUI

struct Home: View {
    ///properties
    @State var activeTag = "Biography"
    @State var carouselMode : Bool = false
    
    @Namespace private  var animation
    
    @State private var showDetailView : Bool = false
    @State private var animateCurrentBook : Bool = false
    @State private var selectedBook : Book?
    
   
    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                Text("Browse")
                    .font(.largeTitle.bold())
                
                Text("Recommended")
                    .fontWeight(.semibold)
                    .padding(.leading, 15)
                    .foregroundColor(.gray)
                    .offset(y: 2)
                Spacer(minLength: 20)
                
                Menu {
                    Button("Toggle Carousel Mode (\(carouselMode ? "On" : "Off"))"){
                        carouselMode.toggle()
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.init(degrees: -90))
                        
                        .foregroundColor(.gray)
                }

            }
            .frame(maxWidth: .infinity , alignment: .leading)
            .padding(.horizontal , 15)
            TagsView()
            GeometryReader{
                let size = $0.size
                ScrollView(.vertical,showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(sampleBooks) { book  in
                            BooksCardView(book)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        animateCurrentBook = true
                                        selectedBook = book
                                    }
                                    DispatchQueue.main.asyncAfter(deadline : .now() + 0.15){
                                        withAnimation(.interactiveSpring(response: 0.6 , dampingFraction: 0.7 , blendDuration: 0.7)){
                                            
                                            showDetailView = true
                                        }
                                    }
                                   
                                }
                        }
                    }.padding(.horizontal , 15)
                     .padding(.vertical , 15)
                     .padding(.bottom , bottomPadding(size))
                     .background{
                         ScrollViewDetector(carouselMode: $carouselMode, totalCardCount: sampleBooks.count)
                     }
                }
                .coordinateSpace(name: "SCROLLVIEW")
            }
            .padding(.top , 15)
        }.overlay {
            Group {
                    if let selectedBook = selectedBook, showDetailView {
                        DetailView(animation: animation, book: selectedBook, show: $showDetailView)
                            .transition(.asymmetric(insertion: .identity, removal: .offset(y  : 5)))
                    }
                }
        }
        .onChange(of: showDetailView) { newValue in
            if !newValue{
                withAnimation(.easeInOut(duration: 0.15).delay(0.3)){
                    animateCurrentBook = false
                }
            }
        }
        
    }
    /// Book card view
    @ViewBuilder
    
    func BooksCardView (_  book : Book )-> some View {
        GeometryReader{
            let size = $0.size
            let rect = $0.frame(in: .named("SCROLLVIEW"))
            
            let minY = rect.minY
            HStack(spacing: 0){
                VStack(alignment: .leading,spacing: 6) {
                    Text(book.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("By Author \(book.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    RatingView(rating: book.rating)
                        .padding(.top ,10)
                    
                    Spacer()
                    
                    HStack(spacing: 10){
                        
                        Text("\(book.bookViews)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("Views")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                    }
                }
                .padding(20)
                .frame(width: size.width/2 , height: size.height * 0.8)
                .background{
                    RoundedRectangle(cornerRadius: 10  ,style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.088), radius: 8,x: 5,y:5)
                        .shadow(color: .black.opacity(0.088), radius: 8,x: -5,y:-5)
                }
                .zIndex(1)
                .offset(x: animateCurrentBook && selectedBook?.id == book.id ? -20 : 0)
                
                
                ZStack{
                    if !(showDetailView && selectedBook?.id == book.id){
                        Image(book.imageName)
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: size.width/2 ,  height: size.height)
                            .matchedGeometryEffect(id: book.id, in: animation)
                            .clipShape(RoundedRectangle(cornerRadius: 10  ,style: .continuous))
                    }
                   
                }
            }.frame(width: size.width)
                .rotation3DEffect(.init(degrees: convertOffsetToRotation(rect)), axis: (x:1,y:0,z:0),anchor: .bottom,anchorZ: 1,perspective: 0.8)
        }.frame(height: 220)
    }
    
    
    func bottomPadding(_ size : CGSize = .zero ) -> CGFloat{
        let cardHeight : CGFloat = 220
        let scrollViewHeight : CGFloat = size.height
        
        return scrollViewHeight - cardHeight - 40
        
    }
    /// Converting MinY to Rotation

    func convertOffsetToRotation (_ rect: CGRect) -> CGFloat {
        let cardHeight = rect.height + 20

        let minY = rect.minY - 20

        let progress = minY < 0 ? (minY / cardHeight) : 0

        let constrainedProgress = min(-progress, 1.0)

        return constrainedProgress * 90

    }

   
    
    /// Tags Views
    
    @ViewBuilder
    
    func TagsView() -> some View {
        
        ScrollView(.horizontal,showsIndicators: false) {
            
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    
                    Text (tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background{
                            if(activeTag  ==  tag) {
                                Capsule()
                                    .fill(.blue)
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }else {
                                Capsule().fill(.gray.opacity(0.2))
                            }
                        }
                        .foregroundColor(activeTag  ==  tag ? .white  : .gray)
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.5 , dampingFraction: 0.7 , blendDuration: 0.7)){
                                activeTag = tag
                            }
                        }
                }
                
            }.padding(.horizontal , 15)
        }
    }
    
    
    
}
var tags: [String] = [
    
    "History", "Classical", "Biography", "Cartoon", "Adventure", "Fairy tales", "Fantasy"
    
]
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


           
                 
/// ScrollView Detector

