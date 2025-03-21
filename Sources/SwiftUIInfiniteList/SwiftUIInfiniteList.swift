import SwiftUI
import SwiftUIPullToRefresh

public struct InfiniteList<Data, Content, LoadingView>: View
where Data: RandomAccessCollection, Data.Element: Hashable, Content: View, LoadingView: View  {
    @Binding var data: Data
    @Binding var isLoading: Bool
    let loadingView: LoadingView
    let loadMore: () -> Void
    let onRefresh: OnRefresh?
    let content: (Data.Element) -> Content
    
    //private let columns: [GridItem] = {
    //    let fixedSize = UIScreen.main.bounds.width / 3
    //    return [
    //        GridItem(.fixed(fixedSize), spacing: 2),
    //        GridItem(.fixed(fixedSize), spacing: 2),
    //        GridItem(.fixed(fixedSize), spacing: 2)
    //    ]
    //}()


    public init(data: Binding<Data>,
         isLoading: Binding<Bool>,
         loadingView: LoadingView,
         loadMore: @escaping () -> Void,
         onRefresh: OnRefresh? = nil,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        _data = data
        _isLoading = isLoading
        self.loadingView = loadingView
        self.loadMore = loadMore
        self.onRefresh = onRefresh
        self.content = content
    }
    
    public var body: some View {
        if onRefresh != nil {
            RefreshableScrollView(onRefresh: onRefresh!) {
                scrollableContent
                    .onAppear(perform: loadMore)
            }
        } else {
            List {
                listItems
            }.onAppear(perform: loadMore)
        }
    }
    
    private var scrollableContent: some View {
        return Group {
            if #available(iOS 14.0, *) {
                //LazyVStack(spacing: 10) {
                //    listItems
                //}
                let fixedSize = UIScreen.main.bounds.width / 3
                let columns = [
                    GridItem(.fixed(fixedSize), spacing: 2),
                    GridItem(.fixed(fixedSize), spacing: 2),
                    GridItem(.fixed(fixedSize), spacing: 2)
                ]
                LazyVGrid(columns: columns, spacing: 2.0) {
                    listItems
                }
            } else {
                VStack(spacing: 10) {
                    listItems
                }
            }
        }
    }
    
    private var listItems: some View {
        Group {
            ForEach(data, id: \.self) { item in
                content(item)
                    .onAppear {
                        if item == data.last {
                            loadMore()
                        }
                    }
            }
            if isLoading {
                loadingView
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
