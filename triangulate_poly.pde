color red = color(214, 58, 55);
color green = color(58, 242, 110);
color blue = color(72, 121, 159);

Polygon poly;
ArrayList<Segment> diag;
boolean start_triangulate = false;

void setup() {
    area = document.getElementById("sketch");
    smooth();
    noLoop();
    size(parseInt(area.style.width), parseInt(area.style.height));
    poly = new Polygon();
    diag = new ArrayList();
    background(45, 51, 58);
}

void draw() {
    area = document.getElementById("sketch");
    noStroke();
    fill(45, 51, 58);
    rect(0, 0, parseInt(area.style.width), parseInt(area.style.height));
    poly.draw();
    if (start_triangulate) {
        diag = triangulate(poly);
        for (int i = 0; i < diag.size(); ++i) {
            diag.get(i).col = red;
            diag.get(i).draw();
        }
    }
}

void mouseClicked() {
    if (mouseButton == LEFT) {
        poly.add(new Point(mouseX, mouseY));
    } else if (mouseButton == RIGHT) {
        start_triangulate = true;
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

    boolean is_equal(Point a) {
        return (this.x == a.x && this.y == a.y);
    }

    void draw() {
        pushStyle();
        fill(this.col);
        strokeWeight(0.5);
        ellipse(x, y, 7, 7);
        popStyle();
    }
};

class Segment {
    Point a, b;
    color col = blue;

    Segment(Point a, Point b) {
        this.a = a;
        this.b = b;
    }

    void draw() {
        pushStyle();
        stroke(this.col);
        strokeWeight(2);
        line(this.a.x, this.a.y, this.b.x, this.b.y);
        this.a.col = this.col;
        this.b.col = this.col;
        a.draw();
        b.draw();
        popStyle();
    }
};

class SetOfPoints {
    ArrayList<Point> points;
    color col = blue;

    SetOfPoints() {
        this.points = new ArrayList();
    }

    SetOfPoints(ArrayList<Point> p) {
        this.points = new ArrayList(p);
    }

    ArrayList getPoints() {
        return this.points;
    }

    ArrayList<Point> subset_p(int index, int max_size) {
        ArrayList p = new ArrayList();
        int n = this.points.size();

        for (int i = index*max_size; (i < n) && (p.size() < max_size); ++i) {
            p.add(this.points.get(i));
        }

        return p;
    }

    void add(Point p) {
        this.points.add(p);
    }

    Point remove(int i) {
        return this.points.remove(i);
    }
    
    boolean remove(Point p) {
        return this.points.remove(p);
    }
    
    int size() {
        return this.points.size();
    }

    Point get(int i) {
        int n = this.size();
        if (i >= 0)
            return this.points.get(i % n);
        else
            return this.points.get((n-1) - (abs(i+1) % n));
    }

    Point last() {
        if (this.points.size() > 0)
            return this.points.get(this.points.size()-1);
        else    
            return null;
    }

    void draw() {
        pushStyle();
        beginShape();
        for (int p = 0; p < this.size(); p++) {
            Point pt = (Point) this.get(p);
            pt.col = this.col;
            pt.draw();
        }
        endShape(CLOSE);
        popStyle();
    }
};

class Polygon extends SetOfPoints {
    Polygon() {
      this.points = new ArrayList();
    }
    
    Polygon(ArrayList<Point> p) {
        this.points = new ArrayList(p);
    }

    Polygon sub_poly(int pi, int pj) {
        Polygon p = new Polygon();
        Point end = this.get(pj);

        for (int i = pi; end != this.get(i); ++i) {
            p.add(this.get(i));
        }
        p.add(end);

        return p;
    }

    boolean is_convex(int pi) {
        return is_right(this.get(pi-1), this.get(pi), this.get(pi+1));
    }

    boolean is_concave(int pi) {
        return is_left(this.get(pi-1), this.get(pi), this.get(pi+1));
    }

    boolean is_neighboor(int pi, int pj) {
        Point a0 = this.get(pi-1);
        Point a = this.get(pi);
        Point a1 = this.get(pi+1);

        Point b0 = this.get(pj-1);
        Point b = this.get(pj);
        Point b1 = this.get(pj+1);

        return ((b.is_equal(a0) || b.is_equal(a1)) && (a.is_equal(b0) || a.is_equal(b1)));
    }

    boolean is_diagonalie(int ia, int ib) {
        Point a = this.get(ia);
        Point b = this.get(ib);

        for (int i = 0; i < this.size(); ++i) {
            Point c = this.get(i);
            Point c1 = this.get(i+1);
            if ( (a.is_equal(c) || a.is_equal(c1) || b.is_equal(c) || b.is_equal(c1)) )
                continue;
            if (intersect(a, b, c, c1) == true)
                return false;
        }
        return true;
    }

    boolean in_cone(int ia, int ib) {
        Point a = this.get(ia);
        Point b = this.get(ib);

        Point a0 = this.get(ia-1);
        Point a1 = this.get(ia+1);

        if (this.is_convex(ia))
            return (is_right(a, b, a0) && is_left(a, b, a1));
        else
            return !(is_left(a, b, a0) && is_right(a, b, a1));
    }

    boolean is_diagonal(int a, int b) {
        return (this.in_cone(a, b) && this.is_diagonalie(a, b));
    }

    boolean is_ear2(int i) {
        if (this.is_concave(i))
            return false;

        if (this.size() <= 2)
            return false;
        else if (this.size() == 3) {
            return this.is_convex(i);
        }

        return this.is_diagonal(i-1, i+1);
    }

    boolean is_ear(int i) {
        if (this.size() <= 3)
            return false;
  
        if (this.is_convex(i)) {
            for (int j = 0; j < this.size(); ++j) {
                if (j == i-1 || j == i || j == i+1)
                    continue;
                else if (is_convex(j))
                    continue;
                else if ( is_in_triangle(this.get(i-1), this.get(i), this.get(i+1), this.get(j)) )
                    return false;
            }
            return true;
        } else {
            return false;
        }
    }

    int find_ear(int pi) {
        if (this.is_ear(pi))
            return pi;

        if (this.size() == 4)
            return pi+1;

        int pj;
        for (pj = pi+3; ; ++pj) {
            if (this.is_diagonal(pi, pj) == true)
                break;
        }

        Polygon sub = new Polygon(this.sub_poly(pi, pj));
        if (sub.size() == 3) {
            return pi+1;
        }
        int ret = sub.find_ear(floor(((float) sub.size())/2.0));
        return this.points.indexOf(sub.get(ret));
    }

    int find_ear() {
        if (this.size() == 3) {
            return 1;
        }

        for (int pj = 0; pj < this.size(); ++pj) {
            if (this.is_ear(pj))
                return pj;
        }
    }

    void draw() {
        pushStyle();
        strokeWeight(3);
        stroke(this.col);
        noFill();
        beginShape();
        for (int p = 0; p < this.points.size(); p++) {
            Point pt = (Point) this.points.get(p);
            vertex(pt.x, pt.y);
            pt.col = this.col;
            pt.draw();
            pushStyle();
            stroke(255);
            fill(255);
            textSize(16);
            text(p, this.get(p).x, this.get(p).y, 20, 20);
            popStyle();
        }
        endShape(CLOSE);
        popStyle();
    }
};

// c is left to ab
boolean is_right(Point a, Point b, Point c) {
    return ((b.y - a.y)*(c.x - a.x) < (b.x - a.x)*(c.y - a.y));
}

// c is right to ab
boolean is_left(Point a, Point b, Point c) {
    return ((b.y - a.y)*(c.x - a.x) > (b.x - a.x)*(c.y - a.y));
}

// c is collinear to ab
boolean is_collinear(Point a, Point b, Point c) {
    return ((b.y - a.y)*(c.x - a.x) == (b.x - a.x)*(c.y - a.y));
}

// c is between ab
boolean between(Point a, Point b, Point c) {
    if (! is_collinear(a, b, c))
        return false;

    if (a.x != b.x)
        return ( ((a.x <= c.x) && (c.x <= b.x)) || ((a.x >= c.x) && (c.x >= b.x)) );
    else
        return ( ((a.y <= c.y) && (c.y <= b.y)) || ((a.y >= c.y) && (c.y >= b.y)) );
}

// determine proper intersection (when two segments intersect at a point interior to both)
boolean intersect_prop(Point a, Point b, Point c, Point d) {
    if (is_collinear(a,b,c) || is_collinear(a,b,d) || is_collinear(c,d,a) || is_collinear(c,d,b))
        return false;
    else if ( (is_left(a,b,c) != is_left(a,b,d)) && (is_left(c,d,a) != is_left(c,d,b)) )
        return true;
    else
        return false;
}

boolean intersect(Point a, Point b, Point c, Point d) {
    if (intersect_prop(a, b, c, d))
        return true;
    else if (between(a,b,c) || between(a,b,d) || between(c,d,a) || between(c,d,b))
        return true;
    else
        return false;
}

bool is_in_triangle(Point a, Point b, Point c, Point p) {
    bool sens = is_right(a, b, c);
    Point[] tri = {a, b, c};
    for (int i = 0; i < 3; i++) {
        if (sens != is_right(tri[i], tri[(i+1)%3], p))
            return false;
    }
    return true;
}

ArrayList<Segment> triangulate(Polygon p) {
    ArrayList<Segment> seg = new ArrayList();
    if (p.size() == 4) {
        int pi = 0;
        if (p.is_ear(pi)) {
            seg.add(new Segment(p.get(pi-1), p.get(pi+1)));
        } else {
            seg.add(new Segment(p.get(pi), p.get(pi+2)));
        }
    } else if (p.size() > 4) {
        int pi = floor((float) p.size()/2.0);

        if (p.is_ear(pi)) {
            seg.add(new Segment(p.get(pi-1), p.get(pi+1)));
            seg.addAll(triangulate(p.sub_poly(pi+1, pi-1)));
        } else {
            int pj;
            for (pj = pi+3; ; ++pj) {
                if (p.is_diagonal(pi, pj) == true)
                    break;
            }
            seg.add(new Segment(p.get(pi), p.get(pj)));
            seg.addAll(triangulate(p.sub_poly(pi, pj)));
            seg.addAll(triangulate(p.sub_poly(pj, pi)));
        }
    }
    return seg;
}
