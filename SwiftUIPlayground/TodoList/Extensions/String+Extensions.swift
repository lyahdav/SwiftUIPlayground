extension String {
    func pluralized(for count: Int) -> String {
        return count == 1 ? self : self + "s"
    }
}
