import SwiftUI
import PhotosUI

struct AddCardView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var cardName: String = ""
    @State private var selectedImageData: Data? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter Caption", text: $cardName)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .zIndex(1)

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    GeometryReader { geometry in
                        let size = geometry.size.width
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(UIColor.tertiarySystemFill))
                            
                            if let selectedImageData,
                               let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size, height: size)
                                    .clipped()
                                    .cornerRadius(10)
                            } else {
                                Image("photo.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size * 0.25, height: size * 0.25)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                        .frame(width: size, height: size)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .zIndex(0)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                
                Button {
                    
                } label: {
                    Text("Save Card")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(cardName.isEmpty || selectedImageData == nil ? Color.gray : Color.blue)
                        .cornerRadius(15)
                        .disabled(cardName.isEmpty || selectedImageData == nil)
                }
                
                Spacer()
            }
            .navigationTitle("Add Card")
            .padding()
        }
    }
}

#Preview {
    AddCardView()
}
