struct FloatingAddButton: View {

    var action: () -> Void

    var body: some View {

        VStack {

            Spacer()

            HStack {

                Spacer()

                Button(action: action) {

                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }

                Spacer()
            }
            .padding(.bottom, 10)
        }
    }
}