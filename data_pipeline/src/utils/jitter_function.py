import math
import random

def add_random_jitter(centroid_lat, centroid_lon, jitter_radius):
    earth_radius = 6378137
    theta = random.uniform(0, 2 * math.pi)
    dist = math.sqrt(random.uniform(0, 1)) * jitter_radius
    dist_x = dist * math.cos(theta)
    dist_y = dist * math.sin(theta)
    dist_lon = (dist_x / (earth_radius * math.cos(centroid_lat * (math.pi / 180)))) * (180 / math.pi)
    dist_lat = (dist_y / earth_radius) * (180 / math.pi)
    new_lat = centroid_lat + dist_lat
    new_lon = centroid_lon + dist_lon
    return new_lat, new_lon
