color red = color(214, 58, 55);
color green = color(58, 242, 110);
color blue = color(72, 121, 159);

SetOfPoints setPoints;

void setup() {
    area = document.getElementById("sketch");
    smooth();
    noLoop();
    size(parseInt(area.style.width), parseInt(area.style.height));
    setPoints = new SetOfPoints();
    background(45, 51, 58);
}

void draw() {
    area = document.getElementById("sketch");
    noStroke();
    fill(45, 51, 58);
    rect(0, 0, parseInt(area.style.width), parseInt(area.style.height));
    setPoints.draw();
    Polygon poly = convex_hull(setPoints.getPoints());
    poly.col = green;
    poly.draw();
}

void mouseClicked() {
    setPoints.add(new Point(mouseX, mouseY));
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

class SetOfPoints {
    ArrayList points;
    color col = blue;

    SetOfPoints() {
        this.points = new ArrayList();
    }

    ArrayList getPoints() {
        return this.points;
    }

    void add(Point &p) {
        this.points.add(p);
    }
    
    int size() {
        return this.points.size();
    }

    Point get(int i) {
        return this.points.get(i);
    }

    void draw() {
        pushStyle();
        beginShape();
        for (int p = 0; p < this.points.size(); p++) {
            Point pt = (Point) points.get(p);
            pt.col = this.col;
            pt.draw();
        }
        endShape(CLOSE);
        popStyle();
    }
};

class Polygon extends SetOfPoints {
    Polygon(ArrayList<Point> p) {
        this.points = p;
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

bool is_cw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) < (b.x - a.x)*(c.y - a.y);
}

bool is_ccw(Point a, Point b, Point c) {
    return (b.y - a.y)*(c.x - a.x) > (b.x - a.x)*(c.y - a.y);
}

bool is_in_triangle(Point a, Point b, Point c, Point p) {
    bool sens = is_cw(a, b, c);
    Point[] tri = {a, b, c};
    for (int i = 0; i < 3; i++) {
        if (sens != is_cw(tri[i], tri[(i+1)%3], p))
            return false;
    }
    return true;
}

Point min(ArrayList<Point> points) {
    Point p = points.get(0);
    for (int i = 1; i < points.size(); ++i) {
        if (points.get(i).x < p.x) {
            p = points.get(i);
        } else if (points.get(i).x == p.x && points.get(i).y < p.y) {
            p = points.get(i);
        }
    }
    return p;
}

Polygon convex_hull(ArrayList<Point> points) {
    if (points.size() <= 3)
        return new Polygon(points);
    
    ArrayList p = new ArrayList(); 
    Point start_point = min(points);
    Point end_point;
    
    int i = 0;
    do {
        p.add(start_point);
        end_point = points.get(0);
        for (int j = 1; j < points.size(); ++j) {
            if ((end_point == start_point) || is_cw(p.get(i), end_point, points.get(j)))
                end_point = points.get(j);
        }
        ++i;
        start_point = end_point;
    } while (end_point != p.get(0));

    return new Polygon(p);
}

Point is_in_ch(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();
    int lo = 1;
    int hi = n-1;

    if (is_cw(p.get(0), p.get(1), q) || is_ccw(p.get(0), p.get(n-1), q))
        return false;

    while (lo < hi-1) {
        int m = floor((lo+hi)/2);

        if (is_cw(p.get(0), p.get(m), q))
            hi = m;
        else
            lo = m;
    }

    if (is_ccw(p.get(lo), p.get(hi), q))
        return true;
    else
        return false;
}

Point upper_tangent(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();

    for (int i = 0; i < n; ++i) {
        Point a = p.get(i);
        Point b = p.get((i+1)%n);
        Point c = p.get((i+n-1)%n);

        if (is_ccw(q, a, b) && is_ccw(q, a, c))
            return a;
    }
}

Point lower_tangent(ArrayList<Point> points, Point q) {
    Polygon ch = convex_hull(points);
    ArrayList<Point> p = ch.getPoints();
    int n = p.size();

    for (int i = 0; i < n; ++i) {
        Point a = p.get(i);
        Point b = p.get((i+1)%n);
        Point c = p.get((i+n-1)%n);

        if (is_cw(q, a, b) && is_cw(q, a, c))
            return a;
    }
}