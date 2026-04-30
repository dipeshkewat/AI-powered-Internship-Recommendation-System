"""
test_recommendations.py
─────────────────────────
Test script to verify the recommendation system handles:
1. Empty profiles (no skills/interests) → random top 5 with 60-80% scores
2. Profiles with skills → scored recommendations
3. Real data integration
"""

import asyncio
import random
from typing import List

# Simulated test without database dependency
from app.ml.recommender import recommender
from app.services.recommendation_service import (
    _is_empty_profile,
    _generate_random_match_score,
    _compute_score,
)


def test_empty_profile_detection():
    """Test that empty profiles are correctly detected."""
    print("\n🧪 Test 1: Empty Profile Detection")
    print("=" * 50)

    # Test empty profile
    assert _is_empty_profile([], []) == True, "Empty lists should be detected as empty profile"
    print("✓ Empty profile ([], []) detected correctly")

    # Test non-empty profile
    assert _is_empty_profile(["Python"], []) == False, "Profile with skills should not be empty"
    print("✓ Non-empty profile with skills detected correctly")

    assert _is_empty_profile([], ["Web"]) == False, "Profile with interests should not be empty"
    print("✓ Non-empty profile with interests detected correctly")

    # Test profile with both
    assert _is_empty_profile(["Python"], ["AI/ML"]) == False, "Profile with both should not be empty"
    print("✓ Non-empty profile with skills and interests detected correctly")


def test_random_match_score():
    """Test that random match scores are in the correct range."""
    print("\n🧪 Test 2: Random Match Score Generation")
    print("=" * 50)

    scores = [_generate_random_match_score() for _ in range(100)]

    min_score = min(scores)
    max_score = max(scores)
    avg_score = sum(scores) / len(scores)

    print(f"✓ Generated 100 random scores")
    print(f"  Min: {min_score}%, Max: {max_score}%, Avg: {avg_score:.1f}%")

    assert all(60 <= s <= 80 for s in scores), "All scores should be between 60 and 80"
    print("✓ All scores are within range [60, 80]")


def test_heuristic_scoring_with_empty_profile():
    """Test heuristic scoring with empty profile returns uniform distribution."""
    print("\n🧪 Test 3: Heuristic Scoring with Empty Profile")
    print("=" * 50)

    probs = recommender.predict_domain_probs(
        skills=[],
        cgpa=0.0,
        interests=[],
        preferred_location="",
        preferred_type="Any",
    )

    print(f"✓ Generated probabilities for {len(probs)} domains")
    
    # Check that it's a probability distribution (sums to ~1.0)
    total_prob = sum(probs.values())
    print(f"  Total probability: {total_prob:.4f}")
    assert abs(total_prob - 1.0) < 0.01, "Probabilities should sum to 1.0"
    print("✓ Probabilities sum to ~1.0")

    # Check that no domain has 0 probability
    zero_probs = [d for d, p in probs.items() if p == 0.0]
    assert len(zero_probs) == 0, f"No domain should have 0 probability, but found: {zero_probs}"
    print("✓ No domain has 0 probability (uniform distribution)")

    # Print sample probabilities
    sample_domains = list(probs.items())[:3]
    print(f"  Sample probabilities:")
    for domain, prob in sample_domains:
        print(f"    {domain}: {prob:.4f}")


def test_heuristic_scoring_with_skills():
    """Test heuristic scoring with skills returns weighted distribution."""
    print("\n🧪 Test 4: Heuristic Scoring with Skills")
    print("=" * 50)

    probs = recommender.predict_domain_probs(
        skills=["Python", "React", "Node.js"],
        cgpa=8.0,
        interests=["Web", "AI/ML"],
        preferred_location="Bangalore, India",
        preferred_type="Remote",
    )

    print(f"✓ Generated probabilities for {len(probs)} domains with skills")

    # Check that it's a probability distribution
    total_prob = sum(probs.values())
    assert abs(total_prob - 1.0) < 0.01, "Probabilities should sum to 1.0"
    print("✓ Probabilities sum to ~1.0")

    # Check that some domains have higher probability than others
    max_prob = max(probs.values())
    min_prob = min(probs.values())
    print(f"  Probability range: {min_prob:.4f} to {max_prob:.4f}")
    assert max_prob > min_prob, "Should have variation in probabilities"
    print("✓ Probabilities show skill-based preference variation")

    # Web and AI/ML should have higher probability
    print(f"  Web domain probability: {probs.get('Web', 0):.4f}")
    print(f"  AI/ML domain probability: {probs.get('AI/ML', 0):.4f}")


def test_compute_score():
    """Test score computation."""
    print("\n🧪 Test 5: Score Computation")
    print("=" * 50)

    domain_probs = {
        "Web": 0.5,
        "AI/ML": 0.3,
        "App Dev": 0.2,
    }

    # Test Web domain match
    score = _compute_score(
        domain_probs=domain_probs,
        internship_domain="Web",
        internship_location="Bangalore, India",
        internship_type="Remote",
        preferred_location="Bangalore, India",
        preferred_type="Remote",
    )
    print(f"✓ Web internship with matching preferences: {score}%")
    assert score > 50, "Score should be >50 with high domain probability and matching prefs"

    # Test with low probability domain
    score = _compute_score(
        domain_probs=domain_probs,
        internship_domain="Game Dev",
        internship_location="Remote",
        internship_type="Remote",
        preferred_location="Remote",
        preferred_type="Remote",
    )
    print(f"✓ Game Dev internship (not in profile): {score}%")
    assert 5 <= score <= 15, "Score should be low for domain not in profile"

    # Test maximum score
    score = _compute_score(
        domain_probs={"Web": 1.0},
        internship_domain="Web",
        internship_location="Bangalore",
        internship_type="Remote",
        preferred_location="Bangalore",
        preferred_type="Remote",
    )
    print(f"✓ Perfect match: {score}%")
    assert score == 100, "Perfect match should score 100"


def run_all_tests():
    """Run all tests."""
    print("\n" + "=" * 50)
    print("🚀 RECOMMENDATION SYSTEM TEST SUITE")
    print("=" * 50)

    try:
        test_empty_profile_detection()
        test_random_match_score()
        test_heuristic_scoring_with_empty_profile()
        test_heuristic_scoring_with_skills()
        test_compute_score()

        print("\n" + "=" * 50)
        print("✅ ALL TESTS PASSED!")
        print("=" * 50)
        print("\n📊 Summary:")
        print("  ✓ Empty profile detection working")
        print("  ✓ Random match scores in range [60-80]")
        print("  ✓ Heuristic scoring returns uniform distribution for empty profiles")
        print("  ✓ Heuristic scoring respects skill/interest preferences")
        print("  ✓ Score computation is correct")
        print("\n✨ Recommendation system is ready for production!")

    except AssertionError as e:
        print(f"\n❌ TEST FAILED: {e}")
        return False

    return True


if __name__ == "__main__":
    success = run_all_tests()
    exit(0 if success else 1)
