import sys
import requests
import re
from bs4 import BeautifulSoup

# Default
VERBOSE = False

# Function to handle verbose or non-verbose output
def variable_output(href: str, link_text: str, verbose: bool):
    """
    Prints link information based on verbosity setting.
    """
    if verbose:
        print(f"Matched Link Text: '{link_text}'")
        print(f"Associated URL: '{href}'")
        print("-" * 30)
    else:
        print(link_text)

# Command-line argument parsing
if len(sys.argv) > 1:
    if re.match(r"^(-v|--verbose)$", sys.argv[1]):
        VERBOSE = True
    else:
        print("Unrecognized argument. We only have -v/--verbose. Exiting.")
        sys.exit(1)
else:
    print("Non-verbose output.")

# --- Main script logic starts here ---

# Fetch the URL content
target_url = "https://github.com/jivoi/awesome-osint" # This is a good test case for IT terms
try:
    response = requests.get(target_url)
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    print(f"Error fetching URL '{target_url}': {e}")
    sys.exit(1)

# Parse the HTML content
soup = BeautifulSoup(response.content, "html.parser")

# Get all <a> tags from the document
links = soup.find_all('a')

# Define parent tags whose descendants should be excluded (navigation, header, footer)
excluded_parents = ['nav', 'header', 'footer']

# Compile regex patterns once for efficiency

# Regex for filtering hrefs:
# Ensures the href is not an anchor, mailto, or javascript link.
href_filter_regex = re.compile(r"^(?!#)(?!mailto:)(?!javascript:).*")

# *** REVISED text_validation_regex ***
# It matches:
# ^                - Start of string
# [A-Za-z0-9 _\-\./#+&]{3,50} - Allowed characters:
#                            - A-Z, a-z (letters)
#                            - 0-9 (digits)
#                            - space ( )
#                            - _ (underscore)
#                            - \- (escaped hyphen for literal match)
#                            - \. (escaped period for literal match)
#                            - \/ (escaped forward slash for literal match)
#                            - \# (escaped hash for literal match)
#                            - \+ (escaped plus for literal match)
#                            - & (ampersand)
#                            - Between 3 and 50 characters long
# $                - End of string
text_validation_regex = re.compile(r"^[A-Za-z0-9 _\-\./#+&]{3,50}$")

print("\n--- Processing Links ---")

for link in links:
    # Check if the link is a descendant of an excluded navigation/structural element
    is_excluded = False
    current_parent = link.find_parent()
    while current_parent:
        if current_parent.name in excluded_parents:
            is_excluded = True
            break
        current_parent = current_parent.find_parent()

    if not is_excluded:
        href = link.get("href")
        link_text = link.text.strip()

        # Apply href and text validation filters
        if href and href_filter_regex.fullmatch(href):
            if text_validation_regex.fullmatch(link_text):
                # Optionally, consider the 'title' attribute if it exists and provides more context
                # title_text = link.get('title')
                # if title_text and len(title_text.strip()) > len(link_text): # If title is longer/more descriptive
                #    # You might prefer the title_text as the term
                #    variable_output(href=href, link_text=title_text.strip(), verbose=VERBOSE)
                # else:
                variable_output(href=href, link_text=link_text, verbose=VERBOSE)
