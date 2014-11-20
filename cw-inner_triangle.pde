Polygon poly;
Point p = null;

color red = color(214, 58, 55);
color green = color(58, 242, 110);
color blue = color(72, 121, 159);

void setup() {
    area = document.getElementById("sketch");
    smooth();
    noLoop();
    size(parseInt(area.style.width), parseInt(area.style.height));
    poly = new Polygon();
    background(45, 51, 58);
}

void draw() {
    area = document.getElementById("sketch");
    noStroke();
    fill(45, 51, 58);
    rect(0, 0, parseInt(area.style.width), parseInt(area.style.height));
    if (poly.points.size() == 3 && is_ccw(poly.points.get(0), poly.points.get(1), poly.points.get(2))) {
        poly.col = red;
    } else if (poly.points.size() == 3 && is_cw(poly.points.get(0), poly.points.get(1), poly.points.get(2))) {
        poly.col = green;
    }
    if (p != null) {
        if (is_in_triangle(poly.get(0), poly.get(1), poly.get(2), p))
            p.col = green;
        else
            p.col = red;
        p.draw();
    }
    poly.draw();
}

void mouseClicked() {
    if (mouseButton == LEFT) {
        if (poly.size() == 3)
            poly.remove(2);
        poly.add(new Point(mouseX, mouseY));
    } else if (mouseButton == RIGHT && poly.size() == 3) {
        p = new Point(mouseX, mouseY);
    }
    redraw();
}

class Point {
    int x, y;
    color col = blue;

    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    void draw() {
        pushStyle();
        fill(this.col);
        strokeWeight(0.5);
        ellipse(x, y, 7, 7);
        popStyle();
    }
};

class Polygon {
    ArrayList points;
    color col = blue;
    
    Polygon() {
        this.points = new ArrayList();
    }

    ArrayList getPoints() {
        return this.points;
    }

    void add(Point &p) {
        this.points.add(p);
    }

    void remove(int i) {
        this.points.remove(i);
    }
    
    int size() {
        return this.points.size();
    }

    Point get(int i) {
        return this.points.get(i);
    }

    void draw() {
        pushStyle();
        strokeWeight(3);
        stroke(this.col);
        noFill();
        beginShape();
        for (int p = 0; p < this.points.size(); p++) {
            Point pt = (Point) points.get(p);
            vertex(pt.x, pt.y);
            pt.col = this.col;
            pt.draw();
        }
        endShape(CLOSE);
        popStyle();
    }
};

bool is_ccw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) > (b.x - a.x)*(c.y - a.y);
}

bool is_cw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) < (b.x - a.x)*(c.y - a.y)
}

bool is_in_triangle(Point a, Point b, Point c, Point p) {
    bool sens = is_ccw(a, b, c);
    Point[] tri = {a, b, c};
    for (int i = 0; i < 3; i++) {
        if (sens != is_ccw(tri[i], tri[(i+1)%3], p))
            return false;
    }
    return true;
}

Polygon convex(Polygon poly) {

}