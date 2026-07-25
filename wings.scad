module wings() {

    linear_extrude(height = 4, center = true)
    polygon([
        [-40,0],
        [15,95],
        [60,60],
        [10,0],
        [60,-60],
        [15,-95]
    ]);
}

wings();