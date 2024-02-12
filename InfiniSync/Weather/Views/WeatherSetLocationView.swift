//
//  WeatherSetLocationView.swift
//  InfiniSync
//
//  Created by Liam Willey on 1/22/24.
//

import SwiftUI
import Combine
import MapKit

struct WeatherSetLocationView: View {
    @ObservedObject var weatherController = WeatherController.shared
    
    @AppStorage("setLocation") var setLocation: String = "Cupertino"
    @AppStorage("displayLocation") var displayLocation : String = "Cupertino"
    @StateObject private var mapSearch = MapSearch()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState var keyboardFocused
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack() {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.medium)
                        .padding(14)
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(NSLocalizedString("set_location", comment: ""))
                    .foregroundColor(.primary)
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            VStack(spacing: 0) {
                VStack {
                    TextField("Address", text: $mapSearch.searchTerm)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            if !mapSearch.locationResults.isEmpty {
                                let location = mapSearch.locationResults[0]
                                displayLocation = location.title
                                setLocation = "\(location.title), \(location.subtitle)"
                                weatherController.tryRefreshingWeatherData()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .focused($keyboardFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    keyboardFocused = true
                                }
                            }
                }
                .padding()
                Divider()
                if mapSearch.locationResults.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        Text(NSLocalizedString("search_for_locations", comment: "Search for Locations"))
                            .font(.title3.weight(.semibold))
                        Text(NSLocalizedString("find_location", comment: "Use the search box above to find\na location"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack {
                            ForEach(mapSearch.locationResults, id: \.self) { location in
                                Button {
                                    displayLocation = location.title
                                    setLocation = "\(location.title), \(location.subtitle)"
                                    weatherController.tryRefreshingWeatherData()
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(location.title)
                                        Text(location.subtitle)
                                            .font(.system(.caption))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .modifier(RowModifier(style: .standard))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    }
}



class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegion(.world)
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        
        $searchTerm
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                self.locationResults = results
            })
            .store(in: &cancellables)
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        currentPromise?(.success(completer.results))
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //currentPromise?(.failure(error))
    }
}

//
//#Preview {
//    WeatherSetLocationView()
//}
